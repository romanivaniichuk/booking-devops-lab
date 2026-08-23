# Incident: OOMKilled

## Symptom

A booking-app container repeatedly restarted and entered CrashLoopBackOff.

## Monitoring

Prometheus fired the BookingAppOOMKilled alert. Grafana showed abnormal application memory behavior during the incident.

## Diagnostic commands

kubectl get pods -n booking
kubectl describe pod <pod-name> -n booking
kubectl top pods -n booking

## Root cause

The application memory limit was intentionally reduced from 256Mi to 64Mi, below its observed baseline usage of approximately 71-73Mi.

## Fix

The memory limit was restored to 256Mi and the Helm release was redeployed.

## Prevention

Memory limits should be based on observed application usage with sufficient headroom. OOMKilled events are monitored through Prometheus.
