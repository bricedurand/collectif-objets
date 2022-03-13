# frozen_string_literal: true

class Recensement < ApplicationRecord
  belongs_to :objet
  has_many_attached :photos

  delegate :commune, to: :objet

  LOCALISATION_EDIFICE_INITIAL = "edifice_initial"
  LOCALISATION_AUTRE_EDIFICE = "autre_edifice"
  LOCALISATION_ABSENT = "absent"
  LOCALISATIONS = [LOCALISATION_EDIFICE_INITIAL, LOCALISATION_AUTRE_EDIFICE, LOCALISATION_ABSENT].freeze

  ETAT_BON = "bon"
  ETAT_CORRECT = "correct"
  ETAT_MAUVAIS = "mauvais"
  ETAT_PERIL = "peril"
  ETATS = [ETAT_BON, ETAT_CORRECT, ETAT_MAUVAIS, ETAT_PERIL].freeze

  SECURISATION_CORRECTE = "en_securite"
  SECURISATION_MAUVAISE = "en_danger"
  SECURISATIONS = [SECURISATION_CORRECTE, SECURISATION_MAUVAISE].freeze

  validates :localisation, presence: true, inclusion: { in: LOCALISATIONS }
  validates :edifice_nom, presence: true, if: -> { autre_edifice? }
  validates :recensable, inclusion: { in: [true, false] }, unless: -> { absent? }
  validates :etat_sanitaire_edifice, presence: true, if: -> { !absent? && recensable? }
  validates :etat_sanitaire, presence: true, inclusion: { in: ETATS }, if: -> { !absent? && recensable? }
  validates :securisation, presence: true, inclusion: { in: SECURISATIONS }, if: -> { !absent? && recensable? }
  validates(
    :photos,
    presence: true,
    if: -> { !absent? && recensable? && !skip_photos },
    blob: {
      content_type: ["image/jpg", "image/jpeg", "image/png"],
      size_range: 0..(20.megabytes)
    }
  )
  validates :objet_id, uniqueness: true

  attr_accessor :confirmation, :skip_photos

  def absent?
    localisation == LOCALISATION_ABSENT
  end

  def autre_edifice?
    localisation == LOCALISATION_AUTRE_EDIFICE
  end

  def editable?
    commune.objets_recensable?
  end
end