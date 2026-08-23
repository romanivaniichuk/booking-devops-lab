# Incident: DB unavailable

## Symptom

The booking application Pods remained running but became NotReady because they could not connect to PostgreSQL.

## Monitoring

Available application replicas dropped to zero and the BookingAppUnavailable alert fired after two minutes.

## Diagnostic commands

kubectl get pods -n booking
kubectl describe pod <pod-name> -n booking
kubectl logs -n booking deploy/booking-app --tail=100
nc -vz booking-postgres 5432

## Root cause

PostgreSQL ingress traffic was intentionally blocked using the Kubernetes NetworkPolicy.

## Fix

The normal PostgreSQL NetworkPolicy was restored, allowing application Pods to connect to port 5432 again.

## Prevention

Monitor readiness and available replicas, test database connectivity from an application-context Pod, and review NetworkPolicy changes before deployment.

## Database password rotation

1. Generate a new database password.
2. Update the PostgreSQL role password.
3. Update the Kubernetes Secret source.
4. Deploy the updated Secret.
5. Restart application Pods so they read the new environment variable.
6. Verify `/ready`.
7. Remove the old credential.
