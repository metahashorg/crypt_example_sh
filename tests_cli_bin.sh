source ./assert_sh/assert.sh

set -e

assert "./metahash_cli_bin.sh gen-tx --send_to=0x009806da73b1589f38630649bdee48467946d118059efd6aab --amount=126894 --nonce=255 --fee=55647" "009806da73b1589f38630649bdee48467946d118059efd6aabfbaeef0100fa5fd9faff0000"

assert "./metahash_cli_bin.sh gen-tx --send_to=0x009806da73b1589f38630649bdee48467946d118059efd6aab --amount=0 --nonce=0 --fee=0" "009806da73b1589f38630649bdee48467946d118059efd6aab00000000"

assert "./metahash_cli_bin.sh gen-tx --send_to=0x009806da73b1589f38630649bdee48467946d118059efd6aab --amount=4294967295 --fee=65535 --nonce=249" "009806da73b1589f38630649bdee48467946d118059efd6aabfbfffffffffafffff900"

assert "./metahash_cli_bin.sh gen-tx --send_to=0x009806da73b1589f38630649bdee48467946d118059efd6aab --amount=4294967296 --fee=65536 --nonce=250" "009806da73b1589f38630649bdee48467946d118059efd6aabfc0000000001000000fb00000100fafa0000"

assert "./metahash_cli_bin.sh gen-tx --send_to=0x009806da73b1589f38630649bdee48467946d118059efd6aab --amount=126894 --nonce=255 --fee=55647 --dataHex=4d79207465787420225c2027" "009806da73b1589f38630649bdee48467946d118059efd6aabfbaeef0100fa5fd9faff000c4d79207465787420225c2027"

assert_end examples
