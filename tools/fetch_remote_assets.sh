#!/bin/sh
# Download banner and promo art generated with Higgsfield into assets/img at build time.
# If a download fails or isn't a JPEG, the committed fallback image is kept and the build continues.
# Run by Vercel via vercel.json; locally: sh tools/fetch_remote_assets.sh
cd "$(dirname "$0")/.." || exit 0

fetch() { # url dest
  tmp="$(mktemp)"
  if curl -fsSL --max-time 60 -o "$tmp" "$1" && [ "$(head -c 3 "$tmp" | od -An -tx1 | tr -d ' \n')" = "ffd8ff" ]; then
    mv "$tmp" "$2" && echo "fetched $2"
  else
    rm -f "$tmp"; echo "skipped $2 (keeping committed copy)"
  fi
}

BASE="https://d2ol7oe51mr4n9.cloudfront.net/user_3KTmjXX4cAWH8jGzSaPzTrftLoi"
fetch "$BASE/7acc3e8a-7757-486b-b00b-4cee3fec3777.jpg" assets/img/hero-owl.jpg
fetch "$BASE/7cfc314e-08ec-41c9-898b-1c3c6c6b852a.jpg" assets/img/promo-owl.jpg
exit 0
