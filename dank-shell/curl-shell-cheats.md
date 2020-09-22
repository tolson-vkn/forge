# JSON Heredoc Cat Shell

How to use heredoc and other tricks for shell and curl

https://stackoverflow.com/questions/17029902

## Ex1

```
generate_post_data()
{
  cat <<EOF
{
  "account": {
    "email": "$email",
    "screenName": "$screenName"
  }
}
EOF
}

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "https://xxx:xxxxx@xxxx-www.xxxxx.com/xxxxx/xxxx/xxxx"
```

## Ex2

1. For variables without spaces in it i.e. 1:
Simply add ' before and after $variable when replacing desired string

```
for i in {1..3}; do \
  curl -X POST -H "Content-Type: application/json" -d \
    '{"number":"'$i'"}' "https://httpbin.org/post"; \
done
```

2. For input with spaces:
Wrap variable with additional " i.e. "el a":

```
declare -a arr=("el a" "el b" "el c"); for i in "${arr[@]}"; do \
  curl -X POST -H "Content-Type: application/json" -d \
    '{"elem":"'"$i"'"}' "https://httpbin.org/post"; \
done
```

## Ex3

```
curl "http://localhost:8080" \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
--data @<(cat <<EOF
{
  "me": "$USER",
  "something": $(date +%s)
  }
EOF
)
```
