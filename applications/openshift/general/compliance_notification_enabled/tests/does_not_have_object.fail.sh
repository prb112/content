#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/monitoring.coreos.com/v1"

prometheus_api="/apis/monitoring.coreos.com/v1/prometheusrules?limit=500"

cat <<EOF > "$kube_apipath$prometheus_api"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "monitoring.coreos.com/v1",
            "kind": "PrometheusRule",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-18T08:16:33Z",
                "generation": 1,
                "labels": {
                    "name": "image-registry-operator-alerts"
                },
                "name": "image-registry-operator-alerts",
                "namespace": "openshift-image-registry",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "b91fb303-5c5e-419d-9946-0bc7c85a565e"
                    }
                ],
                "resourceVersion": "23374",
                "uid": "4059443c-e867-4e0f-a9bd-12fe2f97ff72"
            },
            "spec": {
                "groups": [
                    {
                        "name": "ImageRegistryOperator",
                        "rules": [
                            {
                                "alert": "ImageRegistryStorageReconfigured",
                                "annotations": {
                                    "message": "Image Registry Storage configuration has changed in the last 30\nminutes. This change may have caused data loss.\n"
                                },
                                "expr": "increase(image_registry_operator_storage_reconfigured_total[30m]) \u003e 0",
                                "labels": {
                                    "severity": "warning"
                                }
                            }
                        ]
                    }
                ]
            }
        },
        {
            "apiVersion": "monitoring.coreos.com/v1",
            "kind": "PrometheusRule",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-18T08:01:14Z",
                "generation": 1,
                "labels": {
                    "role": "alert-rules"
                },
                "name": "ingress-operator",
                "namespace": "openshift-ingress-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "b91fb303-5c5e-419d-9946-0bc7c85a565e"
                    }
                ],
                "resourceVersion": "1586",
                "uid": "1c2fb354-dd7e-46a8-9537-ab37d94f52a8"
            },
            "spec": {
                "groups": [
                    {
                        "name": "openshift-ingress.rules",
                        "rules": [
                            {
                                "alert": "HAProxyReloadFail",
                                "annotations": {
                                    "description": "This alert fires when HAProxy fails to reload its configuration, which will result in the router not picking up recently created or modified routes.",
                                    "message": "HAProxy reloads are failing on {{ $labels.pod }}. Router is not respecting recently created or modified routes",
                                    "summary": "HAProxy reload failure"
                                },
                                "expr": "template_router_reload_failure == 1",
                                "for": "5m",
                                "labels": {
                                    "severity": "warning"
                                }
                            },
                            {
                                "alert": "HAProxyDown",
                                "annotations": {
                                    "description": "This alert fires when metrics report that HAProxy is down.",
                                    "message": "HAProxy metrics are reporting that HAProxy is down on pod {{ $labels.namespace }} / {{ $labels.pod }}",
                                    "summary": "HAProxy is down"
                                },
                                "expr": "haproxy_up == 0",
                                "for": "5m",
                                "labels": {
                                    "severity": "critical"
                                }
                            },
                            {
                                "alert": "IngressControllerDegraded",
                                "annotations": {
                                    "description": "This alert fires when the IngressController status is degraded.",
                                    "message": "The {{ $labels.namespace }}/{{ $labels.name }} ingresscontroller is\ndegraded: {{ $labels.reason }}.\n",
                                    "summary": "IngressController is degraded"
                                },
                                "expr": "ingress_controller_conditions{condition=\"Degraded\"} == 1",
                                "for": "5m",
                                "labels": {
                                    "severity": "warning"
                                }
                            },
                            {
                                "alert": "IngressControllerUnavailable",
                                "annotations": {
                                    "description": "This alert fires when the IngressController is not available.",
                                    "message": "The {{ $labels.namespace }}/{{ $labels.name }} ingresscontroller is\nunavailable: {{ $labels.reason }}.\n",
                                    "summary": "IngressController is unavailable"
                                },
                                "expr": "ingress_controller_conditions{condition=\"Available\"} == 0",
                                "for": "5m",
                                "labels": {
                                    "severity": "warning"
                                }
                            }
                        ]
                    }
                ]
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

jq_filter='[.items[] | select(.metadata.name =="compliance") | .metadata.name]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$prometheus_api#$(echo -n "$prometheus_api$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$prometheus_api" > "$filteredpath"
