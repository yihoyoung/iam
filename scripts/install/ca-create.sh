# mac 下 brew install cfssl
# 其他环境 https://github.com/cloudflare/cfssl/releases 下载安装

# CA 配置文件
tee ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "iam": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

# 生成 CA 证书签名请求（CSR）的 JSON 配置文件
tee ca-csr.json << EOF
{
  "CN": "iam-ca",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "marmotedu",
      "OU": "iam"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF
# 配置环境变量
source environment.sh

# 生成 CA 证书和私钥
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# 确认
ls ca*

cfssl certinfo -cert ${IAM_CONFIG_DIR}/cert/ca.pem

cfssl certinfo -csr ${IAM_CONFIG_DIR}/cert/ca.csr

# 生成 http CA 证书签名请求（CSR）的 JSON 配置文件
tee iam-apiserver-csr.json <<EOF
{
  "CN": "iam-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "marmotedu",
      "OU": "iam-apiserver"
    }
  ],
  "hosts": [
    "127.0.0.1",
    "localhost",
    "iam.api.marmotedu.com"
  ]
}
EOF

cfssl gencert -ca=${IAM_CONFIG_DIR}/cert/ca.pem \
 -ca-key=${IAM_CONFIG_DIR}/cert/ca-key.pem \
 -config=${IAM_CONFIG_DIR}/cert/ca-config.json \
 -profile=iam iam-apiserver-csr.json | cfssljson -bare iam-apiserver

sudo mv iam-apiserver*pem ${IAM_CONFIG_DIR}/cert