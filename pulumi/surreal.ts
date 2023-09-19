import * as kx from "@pulumi/kubernetesx"
import { namespace } from "./namespace"
import {
    createIngress, getMount, getVolume, keelAnnotations, urlPostfix,
} from "./utils"
import { DB_USER, DB_PASS } from "./config"

const ident = "surreal"
const ports = { http: 8000 }

const pvc = new kx.PersistentVolumeClaim(ident, {
    metadata: { namespace },
    spec: {
        accessModes: ["ReadWriteOnce"],
        resources: { requests: { storage: "10Gi" } },
    },
})

const pb = new kx.PodBuilder({
    containers: [{
        image: "surrealdb/surrealdb:latest",
        args: ["start", "--user", DB_USER, "--pass", DB_PASS, "file:///data/db"],
        ports,
        volumeMounts: [getMount(pvc, "/data")],
    }],
    nodeSelector: {
        cloud: "contabo"
    },
    volumes: [getVolume(pvc)],
})

const dep = new kx.Deployment(ident, {
    metadata: {
        namespace,
        annotations: keelAnnotations,
    },
    spec: pb.asDeploymentSpec({
        strategy: { type: "Recreate" },
    }),
})

const svc = dep.createService()
// TODO delete, only for developing
createIngress(ident, svc, ident + urlPostfix)
export const surrealService = svc.metadata.name
