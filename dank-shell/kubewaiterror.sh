#/bin/bash
# Modified from https://stackoverflow.com/a/60286538

# Generally; kubectl apply -f somejob.yaml; ./kubewaiterror.sh

# Wait for completion as background process - capture PID
kubectl wait --for=condition=complete job/myjob &
completion_pid=$!

# Wait for failure as background process - capture PID
# Optinally dump sterr because by the time complete exits
# this one will eventually time out and it's a weird noise
kubectl wait --for=condition=failed job/myjob 2> /dev/null && exit 1 &
failure_pid=$! 

# Capture exit code of the first subprocess to exit
wait -n $completion_pid $failure_pid
exit_code=$?

if (( $exit_code == 0 )); then
  echo "Job completed"
else
  echo "Job failed with exit code ${exit_code}, exiting..."
fi

exit $exit_code
