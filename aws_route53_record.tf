resource "aws_route53_record" "route53" {
  zone_id = data.aws_route53_zone.main.id
  name    = "boundary"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.nlb.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
}
