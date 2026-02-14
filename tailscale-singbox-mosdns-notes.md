# Tailscale / sing-box / mosdns 对话整理

## 1) Tailscale 如何进行分流设置
**三类常见方式：**

### A. 子网路由（只走特定网段）
让某台设备作为 subnet router 宣告内网网段，客户端只对这些网段走 Tailscale。
```bash
sudo tailscale up --advertise-routes=192.168.1.0/24,10.0.0.0/24
```
管理台启用路由后，客户端：
```bash
sudo tailscale up --accept-routes=true
```

### B. 出口节点（Exit Node）
指定某台设备为出口节点，客户端可选择是否全流量走该节点。
```bash
sudo tailscale up --advertise-exit-node
```

### C. App Connector（按域名分流）
通过 DNS 域名列表把流量导入 Tailnet（类似智能分流）。需在管理台开启与配置。

---

## 2) sing-box 结合 mosdns 的分流
### 方案 A（稳定）
**mosdns 返回真实 IP，sing-box 按 IP/geoip 分流。**

### 方案 B（高级：fakeip）
**sing-box 生成 fakeip，保留域名信息，mosdns 负责真实解析与分流判断。**

**流程：**
1. DNS 查询到达 sing-box
2. sing-box fakeip 生成假 IP 并返回
3. 流量到达 sing-box 时反查域名
4. 交给 mosdns 进行真实解析与分流决策
5. sing-box 按路由规则走直连/代理

优点：避免 DNS 泄漏、域名分流更准确；
缺点：配置复杂、兼容性需要测试。

---

## 3) 方案 B 配置模板
### mosdns（/etc/mosdns/config.yaml）
```yaml
log:
  level: info

plugins:
  - tag: cn
    type: forward
    args:
      concurrent: 2
      upstreams:
        - addr: 223.5.5.5
        - addr: 119.29.29.29

  - tag: ov
    type: forward
    args:
      concurrent: 2
      upstreams:
        - addr: https://1.1.1.1/dns-query
        - addr: https://8.8.8.8/dns-query

  - tag: geoip_cn
    type: geoip
    args:
      files: [ /etc/mosdns/geoip.dat ]
      codes: [ CN ]

  - tag: main
    type: sequence
    args:
      - exec: $cn
      - exec: $geoip_cn
      - if: "geoip_cn"
        then: [ accept ]
        else:
          - exec: $ov
          - accept

servers:
  - exec: $main
    listeners:
      - 127.0.0.1:5335
```

### sing-box（关键片段）
```json
{
  "dns": {
    "servers": [
      {
        "tag": "mosdns",
        "address": "127.0.0.1",
        "port": 5335
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/16",
      "inet6_range": "fc00::/18"
    },
    "final": "mosdns"
  },

  "route": {
    "rules": [
      { "protocol": "dns", "outbound": "dns-out" },
      { "geoip": "cn", "outbound": "direct" },
      { "geoip": "private", "outbound": "direct" }
    ],
    "final": "proxy"
  },

  "outbounds": [
    { "type": "direct", "tag": "direct" },
    { "type": "dns", "tag": "dns-out" },
    { "type": "your-proxy", "tag": "proxy" }
  ]
}
```

---

## 4) ECS 是什么
**ECS = EDNS Client Subnet**，是 DNS 的扩展。
- 递归 DNS 查询权威 DNS 时，携带“客户端子网信息”。
- 让权威 DNS 返回更接近用户的 CDN IP。
- 优点：就近调度、低延迟。
- 缺点：隐私泄露与缓存碎片问题，因此通常谨慎使用或白名单启用。
