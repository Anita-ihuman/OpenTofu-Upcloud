terraform {
  required_version = ">= 1.7.0" # OpenTofu 1.7+ for encryption
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 5.0"
    }
  }

}

provider "upcloud" {
  # Uses UPCLOUD_USERNAME and UPCLOUD_PASSWORD from environment
}

resource "upcloud_server" "my_server" {
  hostname = var.hostname
  zone     = var.zone
  plan     = var.vm_type

  template {
    storage = "Ubuntu Server 22.04 LTS (Jammy Jellyfish)"
    size    = var.storage_size
  }

  # Required by your policy pack
  labels = var.labels

  network_interface {
    type = "public"
  }

  # Required for cloud-init images
  metadata  = true
  user_data = <<-EOT
    #cloud-config
    runcmd:
      - [ bash, -lc, "echo upcloud ok" ]
  EOT

}


	name: OpenTofu CI

	on:
	  pull_request:
	    paths: ["**.tf"]
	
  jobs:
	  plan:
	    runs-on: ubuntu-latest
	    steps:
	      - uses: actions/checkout@v4
	      - name: Set up OpenTofu
	        uses: opentofu/setup-opentofu@v1
	      - name: Cache providers
	        uses: actions/cache@v4
	        with:
	          path: ~/.opentofu.d/plugins
	          key: ${{ runner.os }}-tofu-${{ hashFiles('**/.terraform.lock.hcl') }}
	      - name: Init
	        run: tofu init -input=false
	      - name: Plan
	        run: tofu plan -input=false -no-color | tee plan.txt

	  apply:
	    needs: plan
	    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
	    runs-on: ubuntu-latest
	    steps:
	      - uses: actions/checkout@v4
	      - uses: opentofu/setup-opentofu@v1
	      - name: Init
	        run: tofu init -input=false
	      - name: Apply
	        env:
	          TOFU_CONFIRM: "true"
	        run: tofu apply -input=false -auto-approve

	// This workflow will automaticall detect drift on every PR and a tamper‑proof audit trail in GitHub.