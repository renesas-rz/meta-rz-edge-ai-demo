#!/bin/sh

INSTALL_DIRECTORY=${1}

mkdir -p scripts

cat > "scripts/rz-edge-ai-demo.sh" <<-EOF
#!/bin/sh

cd ${INSTALL_DIRECTORY}
./rz-edge-ai-demo
EOF
