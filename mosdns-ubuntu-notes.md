# mosdns（Ubuntu/软路由）对话整理

## 1. 软路由场景：更“智能”的 DNS 分流思路
- **ECS + 解析结果校验（geoip/expectIPs）**：
  - 国内 DNS 先解析；如果返回 IP 不在 CN，则回落海外 DNS（通常走代理）。
  - 通过 ECS 让权威 DNS 返回更靠近本地的 CDN 结果。
- **ECS 白名单 + 子网映射**：
  - 参考 NextDNS 的做法，对真正受益的域名才发送 ECS，减少隐私与缓存碎片问题。
- **并行/竞速解析 + 结果校验**：
  - 多上游并行，按结果归属地/RTT 选最合理答案。

参考资料：
- https://xtls.github.io/document/level-1/routing-with-dns.html
- https://nakanishi.me/articles/translate-article-how-we-made-dns-both-fast-and-private-with-ecs/

---

## 2. Ubuntu 安装 mosdns（基础）
```bash
sudo apt update
sudo apt install -y curl unzip

cd /tmp
curl -L -o mosdns.tar.gz https://github.com/IrineSistiana/mosdns/releases/latest/download/mosdns-linux-amd64.zip
unzip mosdns.tar.gz -d mosdns
sudo mv mosdns/mosdns /usr/local/bin/
sudo chmod +x /usr/local/bin/mosdns

mosdns -h
```

---

## 3. 配置目录与 geoip 数据
```bash
sudo mkdir -p /etc/mosdns
sudo curl -L -o /etc/mosdns/geoip.dat \
  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
```

---

## 4. Ubuntu 示例配置（智能分流 + ECS + 校验）
路径：`/etc/mosdns/config.yaml`
```yaml
log:
  level: info

api:
  http: "127.0.0.1:9091"

plugins:
  # 国内上游
  - tag: cn
    type: forward
    args:
      concurrent: 2
      upstreams:
        - addr: 223.5.5.5
        - addr: 119.29.29.29

  # 国外上游（DoH 示例，可配代理拨号）
  - tag: ov
    type: forward
    args:
      concurrent: 2
      upstreams:
        - addr: https://1.1.1.1/dns-query
        - addr: https://8.8.8.8/dns-query
      ecs: 1.2.3.0/24  # 替换成你的公网子网

  # geoip 判断
  - tag: geoip_cn
    type: geoip
    args:
      files:
        - /etc/mosdns/geoip.dat
      codes:
        - CN

  # 主流程
  - tag: main
    type: sequence
    args:
      - exec: $cn
      - exec: $geoip_cn
      - if: "geoip_cn"
        then:
          - accept
        else:
          - exec: $ov
          - accept

servers:
  - exec: $main
    listeners:
      - 127.0.0.1:5353
```

---

## 5. systemd 自启动
`/etc/systemd/system/mosdns.service`
```ini
[Unit]
Description=mosdns
After=network.target

[Service]
ExecStart=/usr/local/bin/mosdns -c /etc/mosdns/config.yaml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

启用：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now mosdns
sudo systemctl status mosdns
```

---

## 6. 局域网其他设备如何使用 Ubuntu 上的 mosdns
### 6.1 监听 LAN
把监听改成：
```yaml
servers:
  - exec: $main
    listeners:
      - 0.0.0.0:53
```
然后：
```bash
sudo systemctl restart mosdns
```

### 6.2 关闭 systemd-resolved（释放 53 端口）
```bash
sudo systemctl disable --now systemd-resolved
sudo rm -f /etc/resolv.conf
echo "nameserver 223.5.5.5" | sudo tee /etc/resolv.conf
```

### 6.3 放行防火墙
```bash
sudo ufw allow 53/udp
sudo ufw allow 53/tcp
```

### 6.4 让局域网设备使用
- 手动设置 DNS = Ubuntu 的 LAN IP
- 或在路由器 DHCP 里下发 DNS = Ubuntu 的 LAN IP（推荐）

测试：
```bash
nslookup google.com 192.168.1.10
```

---

## 7. 国内直连、国外走代理（拨号器 dialer）
示例（Clash/Mihomo SOCKS5：`127.0.0.1:7891`）：
```yaml
plugins:
  - tag: dialer_direct
    type: dialer
    args:
      mode: direct

  - tag: dialer_proxy
    type: dialer
    args:
      mode: socks5
      address: 127.0.0.1:7891

  - tag: cn
    type: forward
    args:
      concurrent: 2
      dialer: dialer_direct
      upstreams:
        - addr: 223.5.5.5
        - addr: 119.29.29.29

  - tag: ov
    type: forward
    args:
      concurrent: 2
      dialer: dialer_proxy
      upstreams:
        - addr: https://1.1.1.1/dns-query
        - addr: https://8.8.8.8/dns-query
      ecs: 1.2.3.0/24
```

---

## 8. 下一步需要确认的信息（用于最终落地配置）
- CPU 架构（x86_64 / arm64）
- 是否需要 DNS 出口走代理（Clash/Mihomo/v2ray/xray）
- 代理端口（如 7891/7890）
- 期望使用 DoH/DoT/UDP
