# ruff: noqa


def nvidia_legacy(deps: list[Resource]) -> list[Resource]:
    ns = Namespace(
        "nvdp-ns",
        metadata=ObjectMetaArgs(name="gpu", labels={"pod-security.kubernetes.io/enforce": "privileged"}),
    )
    svc = ConfigGroup(
        "nvdp-runtimeclass",
        files=["./nvidia/class.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    chart = Chart(
        "nvdp-chart",
        chart="nvidia-device-plugin",
        namespace=ns.metadata.name,
        repository_opts=RepositoryOptsArgs(repo="https://nvidia.github.io/k8s-device-plugin"),
        value_yaml_files=[pulumi.FileAsset("nvidia/nvdp.yml")],
        opts=ResourceOptions(depends_on=svc),
    )
    return [ns, svc, chart]
