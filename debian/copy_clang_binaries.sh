#!/bin/bash -e

# Копирует бинарник clang а также ld и shared-библиотеку libstdc++ в указанную директорию.
# Так повезло, что этого достаточно, чтобы затем собирать код на удалённом сервере с совпадающей версией Ubuntu, но без установленного компилятора.

DST=${1:-.};
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:$PATH"
LD=$(command -v gold || command -v ld.gold || command -v ld)

# You can build a ClickHouse package without clang.
# clang is used for compile but compile is disabled at default.
# https://clickhouse.yandex/docs/en/operations/settings/settings.html#compile
# https://github.com/yandex/ClickHouse/pull/1157#issuecomment-325423466
if [ ! -x "$CLANG" ]; then
    echo "Skip copying clang files because clang executable not found."
    exit 0
fi

if [ ! -x "$LD" ]; then
    echo "Not found executable gold or ld."
    exit 1
fi

cp "$CLANG" "${DST}/clang"
cp "$LD" "${DST}/ld"

STDCPP=$(ldd $CLANG | grep -oE '/[^ ]+libstdc++[^ ]+')

[ -f "$STDCPP" ] && cp "$STDCPP" $DST
