import "@hotwired/turbo-rails"
import "@gouvfr/dsfr/dist/dsfr.module"

import { Application } from '@hotwired/stimulus'
window.Stimulus = Application.start()

import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()

import { registerControllers } from "stimulus-vite-helpers";
const controllers = import.meta.globEager("../stimulus_controllers/**/*_controller.js");
registerControllers(window.Stimulus, controllers);