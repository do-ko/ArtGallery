output "alb_arn" { value = aws_lb.app.arn }
output "alb_dns_name" { value = aws_lb.app.dns_name }
output "alb_sg_id" { value = aws_security_group.alb.id }

output "listener_http_arn" { value = aws_lb_listener.http.arn }

output "fe_tg_arn" { value = aws_lb_target_group.fe.arn }
output "be_tg_arn" { value = aws_lb_target_group.be.arn }
