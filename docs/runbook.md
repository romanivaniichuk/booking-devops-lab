# Booking DevOps Lab Runbook

## Check application

```bash
kubectl get pods -n booking
kubectl get ingress -n booking
```

## Check application logs

```bash
kubectl logs -n booking deploy/booking-app --tail=100
```

## Check PostgreSQL

```bash
kubectl get pod -n booking -l app.kubernetes.io/component=database
kubectl get pvc -n booking
```

## Backup PostgreSQL

```bash
./scripts/backup-postgres.sh
```

## Restore PostgreSQL

Restore is destructive and should be tested on development first.

```bash
./scripts/restore-postgres.sh backups/FILE.sql
```

## Diagnose failed Pod

```bash
kubectl describe pod POD_NAME -n booking
kubectl logs POD_NAME -n booking --previous
```

## Check rollout

```bash
kubectl rollout status deployment/booking-app -n booking
```

## Rollback Helm

```bash
helm history booking -n booking
helm rollback booking REVISION -n booking
```

## Database initialization

Database tables are initialized automatically by the Helm
`booking-db-init` Job during install and upgrade.

Check the latest Job:

```bash
kubectl get jobs -n booking
