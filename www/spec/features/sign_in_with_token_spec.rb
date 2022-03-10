# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Sign in with token", type: :feature, js: true do
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement: "26") }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }

  scenario "sign in with token" do
    visit "/"
    # save_and_open_screenshot
    click_on "Connexion"
    expect(page).to have_text("Connexion")
    fill_in "Email", with: "mairie-albon@test.fr"
    click_on "Recevoir un lien de connexion"

    expect(page).to have_text("Veuillez cliquer sur le lien que vous avez reçu par mail pour vous connecter")
    email = ActionMailer::Base.deliveries.last
    res = email.body.match(%r{/sign_in_with_token\?login_token=([a-z0-9]+)})
    expect(res).not_to be_nil
    sign_in_path = res[0]

    visit(sign_in_path)
    expect(page).to have_text("Vous êtes maintenant connecté")
  end
end
