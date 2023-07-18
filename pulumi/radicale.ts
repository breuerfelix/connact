import * as pulumi from "@pulumi/pulumi"
import * as kx from "@pulumi/kubernetesx"
import { namespace } from "./namespace"
import { createIngress, keelAnnotations, urlPostfix } from "./utils"
import { MONGO_URL, DB_USER, DB_PASS, DB_NAMESPACE, DB_DATABASE } from "./config"
import { surrealService } from "./surreal"

const ident = "radicale"
const ports = { http: 5232 }
const volumeName = "shared"
const DB_URL = pulumi.interpolate`http://${surrealService}:8000/rpc`
const env = { DB_USER, DB_PASS, DB_NAMESPACE, DB_DATABASE, DB_URL }
const imagePullPolicy = "Always"

const pb = new kx.PodBuilder({
    volumes: [{ name: volumeName, emptyDir: {}, }],
    initContainers: [{
        // initialize data so it won't be empty on the first run
        name: "init-sync",
        image: "ghcr.io/breuerfelix/connact/sync:latest",
        imagePullPolicy,
        command: ["/bin/sh"],
        args: [
            "-c", "mkdir -p /usr/app/collections/collection-root; touch /usr/app/collections/.Radicale.lock; node index.js"
        ],
        env,
        volumeMounts: [{ name: volumeName, mountPath: "/usr/app/collections" }],
    }],
    containers: [
        {
            image: "ghcr.io/breuerfelix/connact/radicale:latest",
            imagePullPolicy,
            env: { MONGO_URL },
            ports,
            // folder structure: /var/lib/radicale/collections/collection-root/{username}/all
            volumeMounts: [{ name: volumeName, mountPath: "/var/lib/radicale/collections" }],
        },
        {
            image: "ghcr.io/breuerfelix/connact/sync:latest",
            imagePullPolicy,
            command: ["/bin/sh"],
            args: [
                "-c", "while true; do flock --exclusive /usr/app/collections/.Radicale.lock node index.js; sleep 15; done"
            ],
            env,
            volumeMounts: [{ name: volumeName, mountPath: "/usr/app/collections" }],
        },
    ],
})

const dep = new kx.Deployment(ident, {
    metadata: {
        namespace,
        annotations: keelAnnotations,
    },
    spec: pb.asDeploymentSpec(),
})

const svc = dep.createService()
const ing = createIngress(ident, svc, ident + urlPostfix)
export const radicaleIngress = ing.metadata.name
