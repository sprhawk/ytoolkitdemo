cd Debug
base64 --encode base64.exe base64.b64
base64 --decode base64.b64 base64.tmp
cmp base64.exe base64.tmp
cd ..

cd Release
base64 --encode base64.exe base64.b64
base64 --decode base64.b64 base64.tmp
cmp base64.exe base64.tmp
cd ..
