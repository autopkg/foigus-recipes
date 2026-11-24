#!/usr/local/autopkg/python

import json
import re

from autopkglib import ProcessorError, URLGetter

__all__ = ["MaxonAppURLProvider"]

MANIFEST_URL = (
    "https://packages.maxon.net/manifests"
    "?platform=macos&org=maxon&type=products&family=fuse"
)
BASE_BLOB_URL = "https://mx-app-blob-prod.maxon.net/mx-package-production"
PRODUCT_NAME = "maxon.products.fuse.mxa-combo-installer"


class MaxonAppURLProvider(URLGetter):
    """Queries the Maxon manifests API and returns the latest macOS Maxon App
    zip download URL and version."""

    description = __doc__
    input_variables = {
        "manifest_url": {
            "required": False,
            "default": MANIFEST_URL,
            "description": "URL of the Maxon manifests API endpoint.",
        },
    }
    output_variables = {
        "url": {"description": "Download URL for the latest Maxon App zip."},
        "version": {"description": "Version string of the latest Maxon App."},
    }

    @staticmethod
    def _version_key(entry):
        version_parts = tuple(
            int(p) for p in re.findall(r"\d+", entry.get("version", "0"))
        )
        return (version_parts, entry.get("buildDate", ""))

    def main(self):
        manifest_url = self.env.get("manifest_url", MANIFEST_URL)
        raw_json = self.download(manifest_url, text=True)

        try:
            entries = json.loads(raw_json)
        except json.JSONDecodeError as err:
            raise ProcessorError(f"Failed to parse Maxon manifest JSON: {err}")

        candidates = [
            e
            for e in entries
            if e.get("name") == PRODUCT_NAME
            and e.get("computed", {}).get("azroot")
            and e.get("payload", {}).get("filename")
        ]
        if not candidates:
            raise ProcessorError(
                f"No matching '{PRODUCT_NAME}' entries found in manifest."
            )

        latest = max(candidates, key=self._version_key)
        azroot = latest["computed"]["azroot"].strip("/")
        filename = latest["payload"]["filename"].lstrip("/")

        self.env["version"] = latest["version"]
        self.env["url"] = f"{BASE_BLOB_URL}/{azroot}/{filename}"
        self.output(
            f"Found Maxon App {self.env['version']} at {self.env['url']}"
        )


if __name__ == "__main__":
    PROCESSOR = MaxonAppURLProvider()
    PROCESSOR.execute_shell()

    