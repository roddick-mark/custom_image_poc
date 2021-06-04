#!/usr/bin/env bats

setup() {
    # Create VM on first @test only
    if [[ "$BATS_TEST_NUMBER" -eq 1 ]]; then
      FIXTURE_DIR="$BATS_TEST_DIRNAME/../../../core-tests/fixtures/azure/linux"
      cd $FIXTURE_DIR
      chmod 600 key_pair/test*
      terraform init -input=false -no-color
      terraform plan -input=false -no-color -var-file=testing.tfvars -out=terraform.plan
      terraform apply -input=false -no-color terraform.plan
      sleep 300
    fi

    FIXTURE_DIR="$BATS_TEST_DIRNAME/../../../core-tests/fixtures/azure/linux"
    cd $FIXTURE_DIR
    tf_output=$(terraform output -json)
    export VM_NAME=$(echo $tf_output | jq -r '.vm_name.value')
    export PIP=$(echo $tf_output | jq -r '.pip.value')
    export USER=$(echo $tf_output | jq -r '.user.value')
    export SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i key_pair/test_1_vm $USER@$PIP -q"

}

@test "run all linux core tests" {
  run bats -r --formatter junit --output $BATS_TEST_DIRNAME "$BATS_TEST_DIRNAME/../../../core-tests/tests/linux"
  echo "# $BATS_TEST_NAME status = ${status}" 
  echo "# $BATS_TEST_NAME output = ${output}" 
  [ $status -eq 0 ]
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip

    if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
      terraform destroy -input=false -no-color -auto-approve -var-file=testing.tfvars
    fi
}