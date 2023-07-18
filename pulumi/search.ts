import * as kx from "@pulumi/kubernetesx"
import { namespace } from "./namespace"
import { createIngress, keelAnnotations, urlPostfix } from "./utils"
import { JWT_SECRET, MONGO_URL } from "./config"

const ident = "search"
const ports = { http: 80 }

const pb = new kx.PodBuilder({
    containers: [{
        image: "ghcr.io/breuerfelix/connact/search:latest",
        imagePullPolicy: "Always",
        env: {
            MONGO_URL,
            JWT_SECRET,
        },
        ports,
    }],
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
export const authIngressName = ing.metadata.name
