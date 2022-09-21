resource "null_resource" "do_nothing" {
  count = 3

  connection {
    type=ssh
    user = "ubuntu"
    host="54.91.187.112"
    private_key="${file("/home/ubuntu/.ssh/id_rsa")}"
    agent = true
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
}
