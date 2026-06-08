#!/bin/sh

set -e

fatal() {
  echo "⛔ " "$@" >&2
  exit 1
}

set_insecure_flag() {
  local downloader=$1
  flag=""

  if [ "${VERIFY}" = "false" ]; then
    echo "🙈 Ignoring security verification"

    case $downloader in
      curl)
        flag="--insecure"
        ;;
      wget)
        flag="--no-check-certificate"
        ;;
      *)
        fatal "Incorrect downloader executable [${downloader}]"
        ;;
    esac
  fi
}

download() {
  local source=$1
  local name=$2

  echo "⏬ Downloading certificate from ${source}"
  echo "📁 Save certificate to ${name}"

  if [ -x "$(which wget)" ]; then
    set_insecure_flag wget
    wget -q $flag $source -O $name
  elif [ -x "$(which curl)" ]; then
    set_insecure_flag curl
    curl -sfL $flag $source -o $name
  else
    fatal "Could not find curl or wget, please install one."
  fi
}

verify_fingerprint() {
  local file_path=$1
  local expected=$2

  # Skip verification if no fingerprint was provided for this index
  if [ -z "$expected" ]; then
    return 0
  fi

  echo "🔍 Verifying SHA-256 fingerprint for ${file_path}..."

  if ! command -v openssl > /dev/null 2>&1; then
    fatal "openssl is required to verify certificate fingerprints but could not be found."
  fi

  local actual
  actual=$(openssl x509 -in "$file_path" -noout -sha256 -fingerprint | cut -d'=' -f2)

  # Convert both strings to uppercase for a safe, case-insensitive comparison
  local actual_upper=$(echo "$actual" | tr '[:lower:]' '[:upper:]')
  local expected_upper=$(echo "$expected" | tr '[:lower:]' '[:upper:]')

  if [ "$actual_upper" != "$expected_upper" ]; then
    fatal "Fingerprint mismatch for ${file_path}! Expected [${expected_upper}], but got [${actual_upper}]."
  else
    echo "✅ Fingerprint matches!"
  fi
}

create_bundle() {
  local filename=$1

  if [ "${BUNDLE}" = "true" ]; then
    local bundle="${filename}.bundle.crt"

    echo "📦 Creating certificate bundle ${bundle}"
    cat $(ls -1 -d "${dest_dir}/"* | grep "${filename}.*") > "${dest_dir}/${bundle}"
  fi
}

echo "🔛 Activating feature '🔒 custom-root-ca'"

counter=0
filename=$(echo $NAME | cut -d . -f 1)
extension=$(echo $NAME | cut -d . -f 2-)
certs=$(echo $SOURCE | tr ',' '\n')
dest_dir=/usr/local/share/ca-certificates

mkdir -p $dest_dir

for i in $certs; do
  # Extract the Nth fingerprint corresponding to the Nth URL
  idx=$((counter + 1))
  expected_fp=$(echo "$FINGERPRINTS" | awk -v col="$idx" -F',' '{print $col}')

  if [ $counter -eq 0 ]; then
    dest_file="${dest_dir}/${filename}.${extension}"
  else
    dest_file="${dest_dir}/${filename}-${counter}.${extension}"
  fi

  download "${i}" "${dest_file}"
  verify_fingerprint "${dest_file}" "${expected_fp}"

  counter=$((counter + 1))
done

create_bundle $filename

update-ca-certificates
