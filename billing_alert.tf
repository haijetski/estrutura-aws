# 1- Criando o tópico SNS
resource "aws_sns_topic" "billing_topic" {
  name = "billing-alerts"
}

# 2- Inscrevendo um e-mail para receber notificações
resource "aws_sns_topic_subscription" "billing_subscription" {
  topic_arn = aws_sns_topic.billing_topic.arn
  protocol  = "email"
  endpoint  = "seu-email@example.com" # Insira o e-mail para receber o alerta
}

# 3- Criando o alarme de Billing no Cloudwatch
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "BillingAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold" # Dispara o alarme se o valor monitorado for maior ou igual ao limite definido.
  evaluation_periods  = "1"                             # Define que a condição deve ser verdadeira por 1 período de avaliação para disparar o alarme.
  metric_name         = "EstimatedCharges"              # Métrica monitorada, que é o valor estimado das cobranças (faturamento) da AWS.
  namespace           = "AWS/Billing"                   # Define o namespace da métrica de faturamento no CloudWatch.
  period              = "21600"                         # Define o período de avaliação como 6 horas (21600 segundos).
  statistic           = "Maximum"                       # Usa o valor máximo da métrica no período.
  threshold           = "100"                           # Valor limite, ex: 100 dólares
  actions_enabled     = true                            # Ativa as ações de alarme (enviar notificações).
  alarm_description   = "Alarme de Faturamento quando os custos excederem 100 USD."
  unit                = "None" # A métrica não precisa de uma unidade específica (como dólares ou segundos).

  alarm_actions = [
    aws_sns_topic.billing_topic.arn
  ]

  dimensions = {
    Currency = "USD" # Define a moeda para a métrica de faturamento como Dólar Americano.
  }
}