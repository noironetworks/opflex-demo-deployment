resource "null_resource" "edit_cft" {
  provisioner "local-exec" {
    command = <<EOF
cp cft cft_mod &&
sed -i -e 's/"ManagedPolicyName": "ApicAdminFullAccess"/"ManagedPolicyName": "ApicAdminFullAccess${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"ManagedPolicyName": "ApicACMReadOnlyPolicy"/"ManagedPolicyName": "ApicACMReadOnlyPolicy${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"ManagedPolicyName": "ApicTenantsAccess"/"ManagedPolicyName": "ApicTenantsAccess${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"RoleName": "ApicAdminReadOnly"/"RoleName": "ApicAdminReadOnly${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"RoleName": "ApicAdmin"/"RoleName": "ApicAdmin${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rApicAdminReadOnlyRole"/"rApicAdminReadOnlyRole${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rApicAdminRole"/"rApicAdminRole${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rInfraVPC"/"rInfraVPC${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rInfraVPCIgwAttachment"/"rInfraVPCIgwAttachment${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rInfraVPCPublicRouteTable"/"rInfraVPCPublicRouteTable${random_string.suffix.result}"/g' cft_mod &&
sed -i -e 's/"rInfraVPCPublicRoute"/"rInfraVPCPublicRoute${random_string.suffix.result}"/g' cft_mod &&
cat cft_mod
EOF
  }

}

resource "aws_cloudformation_stack" "network" {
  name = "${var.name_prefix}-capic-${random_string.suffix.result}"

  parameters = {
    pInfraVPCPool     = "${var.capic_vpc_cidr}"
    pAvailabilityZone = "${var.aws_region}${var.aws_availability_zone}"
    pPassword         = "${var.capic_password}"
    pConfirmPassword  = "${var.capic_password}"
    pKeyName          = "${aws_key_pair.deployer.key_name}"
  }
  capabilities        = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  template_body = <<STACK
${file("cft_mod")}
STACK
  depends_on = [
    "null_resource.edit_cft",
  ]
}
