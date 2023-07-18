
import * as pulumi from "@pulumi/pulumi"
import * as kx from "@pulumi/kubernetesx"
import { namespace } from "./namespace"
import { createIngress, keelAnnotations, urlPostfix } from "./utils"
import { JWT_SECRET, DB_USER, DB_PASS, DB_DATABASE, DB_NAMESPACE } from "./config"
import { surrealService } from "./surreal"

const ident = "relation"
const ports = { http: 8080 }

const pb = new kx.PodBuilder({
    containers: [{
        image: "ghcr.io/breuerfelix/connact/relation:latest",
        imagePullPolicy: "Always",
        env: {
            JWT_SECRET,
            DB_USER,
            DB_PASS,
            DB_NAMESPACE,
            DB_DATABASE,
            PORT: "8080",
            DB_URL: pulumi.interpolate`http://${surrealService}:8000/rpc`,
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
export const usersIngressName = ing.metadata.name
