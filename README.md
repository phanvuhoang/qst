# QST — Dockerized for Dokploy

[QST](https://qstonline.org) is an open-source assessment/exam platform (Perl + mod_perl + MySQL).

This repo provides Docker configuration for easy deployment on Dokploy.

## Deploy on Dokploy

1. Add this repo as a source
2. Use `docker-compose.yml` (raw compose mode)
3. Set Traefik labels or use Dokploy's domain routing

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `QST_DB_HOST` | `localhost` | MySQL hostname |
| `QST_DB_NAME` | `qst` | Database name |
| `QST_DB_USER` | `qst` | Database user |
| `QST_DB_PASS` | `Qst#captain2` | Database password |

## License

GPL v2 — see qst_gpl/GNU_GPL2.txt
