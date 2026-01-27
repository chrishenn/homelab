# Test Win Node

```yaml
# win-webserver.yaml
---
apiVersion: v1
kind: Service
metadata:
    name: win-webserver
    labels:
        app: win-webserver
spec:
    ports:
        # the port that this service should serve on
        - port: 80
          targetPort: 80
    selector:
        app: win-webserver
    type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
    labels:
        app: win-webserver
    name: win-webserver
spec:
    replicas: 2
    selector:
        matchLabels:
            app: win-webserver
    template:
        metadata:
            labels:
                app: win-webserver
            name: win-webserver
        spec:
            containers:
                - name: windowswebserver
                  image: mcr.microsoft.com/windows/servercore:ltsc2022
                  command:
                      - powershell.exe
                      - -command
                      - "<#code used from https://gist.github.com/19WAS85/5424431#> ; $$listener = New-Object System.Net.HttpListener ; $$listener.Prefixes.Add('http://*:80/') ; $$listener.Start() ; $$callerCounts = @{} ; Write-Host('Listening at http://*:80/') ; while ($$listener.IsListening) { ;$$context = $$listener.GetContext() ;$$requestUrl = $$context.Request.Url ;$$clientIP = $$context.Request.RemoteEndPoint.Address ;$$response = $$context.Response ;Write-Host '' ;Write-Host('> {0}' -f $$requestUrl) ;  ;$$count = 1 ;$$k=$$callerCounts.Get_Item($$clientIP) ;if ($$k -ne $$null) { $$count += $$k } ;$$callerCounts.Set_Item($$clientIP, $$count) ;$$ip=(Get-NetAdapter | Get-NetIpAddress); $$header='<html><body><H1>Windows Container Web Server</H1>' ;$$callerCountsString='' ;$$callerCounts.Keys | % { $$callerCountsString+='<p>IP {0} callerCount {1} ' -f $$ip[1].IPAddress,$$callerCounts.Item($$_) } ;$$footer='</body></html>' ;$$content='{0}{1}{2}' -f $$header,$$callerCountsString,$$footer ;Write-Output $$content ;$$buffer = [System.Text.Encoding]::UTF8.GetBytes($$content) ;$$response.ContentLength64 = $$buffer.Length ;$$response.OutputStream.Write($$buffer, 0, $$buffer.Length) ;$$response.Close() ;$$responseStatus = $$response.StatusCode ;Write-Host('< {0}' -f $$responseStatus)  } ; "
            nodeSelector:
                kubernetes.io/os: windows
```

```bash
kubectl create -f win-webserver.yaml
k get pods -o wide -w
```

1. Check that the deployment succeeded. To verify:
    - Several pods listed from the Linux control plane node, use`kubectl get pods`
    - Node-to-pod communication across the network,`curl`port 80 of your pod IPs from the Linux control plane node to
      check for a web server response
    - Pod-to-pod communication, ping between pods (and across hosts, if you have more than one Windows node) using
      `kubectl exec`
    - Service-to-pod communication,`curl`the virtual service IP (seen under`kubectl get services`) from the Linux
      control plane node and from individual pods
    - Service discovery,`curl`the service name with the
      Kubernetes[default DNS suffix](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#services)
    - Inbound connectivity,`curl`the NodePort from the Linux control plane node or machines outside of the cluster
    - Outbound connectivity,`curl`external IPs from inside the pod using`kubectl exec`

```bash
k get pods -o wide
curl pod -p 80
```
