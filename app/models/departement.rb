# frozen_string_literal: true

class Departement < ApplicationRecord
  has_many :communes, dependent: :nullify, foreign_key: :departement_code, inverse_of: :departement
  has_many :objets, through: :communes
  has_many :conservateur_roles, dependent: :destroy, foreign_key: :departement_code, inverse_of: :departement
  has_many :conservateurs, through: :conservateur_roles

  def self.include_communes_count
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT "departement_code", COUNT(*) communes_count
          FROM communes
          GROUP BY "departement_code"
        ) a ON a."departement_code" = departements.code
      }
    ).select("departements.*, COALESCE(a.communes_count, 0) AS communes_count")
  end

  def self.include_objets_count
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT communes.departement_code, COUNT(objets.id) objets_count
          FROM objets
          LEFT JOIN communes ON communes.code_insee = objets."palissy_INSEE"
          GROUP BY communes.departement_code
        ) b ON b."departement_code" = departements.code
      }
    ).select("departements.*, COALESCE(b.objets_count, 0) AS objets_count")
  end

  default_scope { order(code: :asc) }

  def self.admin_select_options
    all.map { [_1.to_s] }
  end

  def to_s
    [code, name].join(" - ")
  end

  def to_h
    # DEPRECATE
    %i[code name communes_count objets_count].map { [_1, send(_1)] }.to_h
  end

  alias display_name to_s
end