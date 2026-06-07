# Certificate Updater notes

The `cert-update` feature imports custom certificate authority (CA) certificates
into the container trust store during feature installation. Use it when a dev
container needs to trust a corporate proxy, private package feed, internal
service, or any other TLS endpoint signed by a private CA.

## What happens during installation

1. The feature chooses the certificate destination.
   - If `certDirectory` is set, that directory is used exactly as provided.
   - Otherwise, Debian-style images with `update-ca-certificates` use
     `/usr/local/share/ca-certificates`.
   - RHEL/Fedora-style images with `update-ca-trust` use
     `/etc/pki/ca-trust/source/anchors`.
2. The feature creates the destination directory if it does not already exist.
3. If `sourceCertificateDirectory` is set, every top-level `*.crt` file from
   that directory is copied into the chosen destination.
4. If `testCertificate` is `true`, the feature generates a temporary
   self-signed test CA certificate in the same destination.
5. The feature counts the `*.crt` files in the destination and updates the
   system trust store with the supported CA update command.

## Supplying your own certificates

Mount or copy PEM-encoded CA certificates with a `.crt` extension into the
container, then point `sourceCertificateDirectory` at that location. For
example:

```jsonc
{
  "features": {
    "ghcr.io/KingBain/devcontainer-features/cert-update:1": {
      "sourceCertificateDirectory": "/tmp/corporate-certs",
    },
  },
  "mounts": [
    "source=${localEnv:HOME}/corporate-certs,target=/tmp/corporate-certs,type=bind,readonly",
  ],
}
```

Only files directly inside `sourceCertificateDirectory` that end in `.crt` are
copied. Subdirectories and files with other extensions are ignored.

## Required certificate behavior

By default, `required` is `true`, so installation fails when no `*.crt` files
are available in the final destination. Set `required` to `false` when
certificates are optional, such as when different developers may or may not have
a local certificate mount.

```jsonc
{
  "features": {
    "ghcr.io/KingBain/devcontainer-features/cert-update:1": {
      "sourceCertificateDirectory": "/tmp/corporate-certs",
      "required": false,
    },
  },
}
```

## When to set `certDirectory`

Most users should leave `certDirectory` unset so the feature can pick the correct
trust-store layout for the base image. Set it only when using a custom image with
a non-standard CA certificate location or when you need to override the detected
destination.

## Testing the feature

Set `testCertificate` to `true` only for validation scenarios. It creates a
temporary CA certificate so tests can verify that trust-store updates run even
when no external certificate bundle is mounted.
