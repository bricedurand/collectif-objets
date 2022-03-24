# frozen_string_literal: true

class Commune < ApplicationRecord
  DISPLAYABLE_DEPARTEMENTS = %w[51 52 65 72 26 30].freeze
  STATUS_INACTIVE = "inactive"
  STATUS_ENROLLED = "enrolled"
  STATUS_STARTED = "started"
  STATUS_COMPLETED = "completed"
  STATUSES = [STATUS_INACTIVE, STATUS_ENROLLED, STATUS_COMPLETED, STATUS_STARTED].freeze

  has_many :users, dependent: :restrict_with_exception
  has_many(
    :objets,
    foreign_key: :commune_code_insee,
    primary_key: :code_insee,
    inverse_of: :commune,
    dependent: :restrict_with_exception
  )
  has_many :recensements, through: :objets

  validates :status, inclusion: { in: STATUSES }

  scope :has_recensements_with_missing_photos, lambda {
    joins(:recensements).merge(Recensement.missing_photos).group(:id)
  }
  scope :recensements_photos_presence_in, lambda { |presence|
    presence ? all : has_recensements_with_missing_photos
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:recensements_photos_presence_in]
  end

  def self.include_objets_count
    joins(
      %{
       LEFT OUTER JOIN (
         SELECT commune_code_insee, COUNT(*) objets_count
         FROM   objets
         GROUP BY commune_code_insee
       ) a ON a.commune_code_insee = communes.code_insee
     }
    ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
  end

  # rubocop:disable Metrics/AbcSize
  def self.select_best_objets(objets_arr)
    objets_arr
      .optional_filter { _1.image_urls.any? }
      .optional_filter { _1.nom.exclude?(";") }
      .optional_filter { !_1.nom.match?(/[A-Z]/) }
      .optional_filter { _1.edifice_nom.present? }
      .optional_filter { _1.edifice_nom&.match?(/[A-Z]/) }
      .optional_filter { _1.emplacement.blank? }
  end
  # rubocop:enable Metrics/AbcSize

  def main_objet
    @main_objet ||=
      Commune.select_best_objets(objets.where.not(nom: nil).to_a).first
  end

  def inactive?
    status == STATUS_INACTIVE
  end

  def enrolled?
    status == STATUS_ENROLLED
  end

  def started?
    status == STATUS_STARTED
  end

  def enrolled_or_started?
    [STATUS_ENROLLED, STATUS_STARTED].include?(status)
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def objets_recensable?
    inactive? || enrolled_or_started?
  end

  def start!
    return true if completed? || started?

    update!(status: STATUS_STARTED)
  end
end