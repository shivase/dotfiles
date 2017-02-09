
# bcpad + borlandでエラーにならない用clang c89モード
bclang () {
    local fname_ext="${1##*/}"
    local fname="${fname_ext%.*}"

    clang -Wall -Wextra -ansi -pedantic $1 -o $fname
}
