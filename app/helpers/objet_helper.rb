# frozen_string_literal: true

module ObjetHelper
  def objet_first_image_or_recensement_photo_url(objet)
    return objet.palissy_photos.first["url"] if objet.palissy_photos.any?

    if objet.current_recensement&.photos&.attached? && can_see_recensement_for(objet)
      return objet.current_recensement.photos.first.variant(:medium)
    end

    "images/illustrations/photo-manquante.png"
  end

  def edifice_nom(nom)
    return nom.capitalize if nom.present?

    content_tag(:i, "Édifice non renseigné")
  end

  def palissy_url(objet)
    "https://www.pop.culture.gouv.fr/notice/palissy/#{objet.palissy_REF}"
  end

  def link_to_palissy(objet, **kwargs, &)
    link_to(palissy_url(objet), target: "_blank", rel: "noopener", **kwargs, &)
  end

  def objet_recensement_badge_color_and_text(objet)
    recensement = objet.current_recensement
    dossier = recensement&.dossier
    return nil if dossier&.rejected? || dossier&.accepted?

    {
      nil => ["", "Pas encore recensé"],
      "completed" => %w[success Recensé],
      "draft" => ["info", "Recensement à compléter"]
    }[recensement&.status]
  end

  def objet_recensement_badge(objet)
    color, text = objet_recensement_badge_color_and_text(objet)
    content_tag(:span, class: "fr-badge fr-badge--md fr-badge--#{color}") { text }
  end

  private

  def can_see_recensement_for(objet)
    current_user&.commune == objet.commune
  end
end
