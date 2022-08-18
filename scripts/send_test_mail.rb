# frozen_string_literal: true

ActionMailer::Base.mail(
  from: "collectifobjets@beta.gouv.fr",
  to: "adrien@dipasquale.fr",
  subject: "Envoi #{Time.zone.now.to_i} d'un dossier Collectif Objets",
  content_type: "text/html",
  body: "<h1>Ceci est un test</h1><p>timestamp: #{Time.zone.now.to_i}</p>"
).deliver_now!