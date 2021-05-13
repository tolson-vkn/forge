results=();
for query in {1..5}; do
    results+=($(dig +trace +noall +stats google.com | grep Query | awk '{print $4}' | paste -s -d+ - | bc));
done

total=0
len=${#results[@]}

for query_time in "${results[@]}"; do
    let total+=$query_time
done

echo "Average query of $len dig traces: $((total / len))"
