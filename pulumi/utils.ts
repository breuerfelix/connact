import * as k8s from "@pulumi/kubernetes"
import * as pulumi from "@pulumi/pulumi"

const urlPostfix = ".connact.tecios.de"

const keelAnnotations = {
    "keel.sh/policy": "force",
    "keel.sh/trigger": "poll",
    "keel.sh/pollSchedule": "@every 30m",
}


function getIngress(...domains: string[]) {
    const hosts = domains.map(host => ({
        host,
        paths: [{ path: "/", pathType: "Prefix" }],
    }))
    const ingressClassName = "traefik"
    return {
        ingressClassName,
        annotations: {
            "kubernetes.io/ingress.class": ingressClassName,
            "cert-manager.io/cluster-issuer": "letsencrypt",
        },
        hosts,
        tls: [{
            secretName: domains.join('-').replace(/\./g, '-') + '-tls',
            hosts: domains,
        }],
    }
}

function getMount(pvc: k8s.core.v1.PersistentVolumeClaim, mountPath: string)
    : k8s.types.input.core.v1.VolumeMount {
    return {
        name: pvc.metadata.name,
        mountPropagation: "HostToContainer",
        mountPath,
    }
}

function getVolume(pvc: k8s.core.v1.PersistentVolumeClaim)
    : k8s.types.input.core.v1.Volume {
    return {
        name: pvc.metadata.name,
        persistentVolumeClaim: {
            claimName: pvc.metadata.name,
        },
    }
}

function createIngress(ident: string, service: k8s.core.v1.Service, ...domains: string[]): k8s.networking.v1.Ingress {
    const rules = domains.map(host => ({
        host,
        http: {
            paths: [{
                path: "/",
                pathType: "Prefix",
                backend: {
                    service: {
                        name: service.metadata.name,
                        port: { name: "http" },
                    },
                },
            }],
        },
    }))

    return new k8s.networking.v1.Ingress(ident, {
        metadata: {
            namespace: service.metadata.namespace,
            name: service.metadata.name,
            annotations: {
                "kubernetes.io/ingress.class": "traefik",
                "cert-manager.io/cluster-issuer": "letsencrypt",
            },
        },
        spec: {
            tls: [{
                secretName: pulumi.interpolate`${service.metadata.name}-tls`,
                hosts: domains,
            }],
            rules,
        },
    })
}

export {
    getIngress,
    getMount,
    getVolume,
    createIngress,
    keelAnnotations,
    urlPostfix,
}
