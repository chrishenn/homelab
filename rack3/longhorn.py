import pulumi
import pulumi_kubernetes as kubernetes
from pulumi_kubernetes.helm.v3 import RepositoryOptsArgsDict


def longhorn():
    k8s_namespace = "nginx-ingress"
    app_labels = {
        "app": "nginx-ingress",
    }

    ingress_ns = kubernetes.core.v1.Namespace(
        "ingressns",
        metadata=kubernetes.meta.v1.ObjectMetaArgs(
            labels=app_labels,
            name=k8s_namespace,
        ),
    )

    ingresscontroller = kubernetes.helm.v3.Release(
        "ingresscontroller",
        chart="nginx-ingress",
        namespace=ingress_ns.metadata.name,
        repository_opts=RepositoryOptsArgsDict(repo="https://helm.nginx.com/stable"),
        skip_crds=True,
        values={
            "controller": {
                "enableCustomResources": False,
                "appprotect": {
                    "enable": False,
                },
                "appprotectdos": {
                    "enable": False,
                },
                "service": {
                    "extraLabels": app_labels,
                },
            },
        },
        version="0.14.1",
    )

    pulumi.export("name", ingresscontroller.name)
