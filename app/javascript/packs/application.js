// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("local-time").start()

window.Rails = Rails

import 'bootstrap'
import 'data-confirm-modal'

$(document).on("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
})

document.addEventListener('turbolinks:load', () => {
  const form = document.querySelector('#payment-form')
  if (form === null) { return }

  const public_key = document.querySelector('meta[name="stripe-key"]').getAttribute('content')
  const stripe = Stripe(public_key)

  const elements = stripe.elements()
  const card = elements.create('card')

  card.mount('#card-element')

  card.addEventListener('change', event => {
    var displayError = document.getElementById('card-errors')
    if (event.error) {
      displayError.textContent = event.error.message
    } else {
      displayError.textContent = ''
    }
  })

  form.addEventListener('submit', event => {
    event.preventDefault()

    let data = {
      payment_method: {
        card: card,
        billing_details: {
          name: document.querySelector('#name_on_card').value
        }
      }
    }

    stripe.confirmCardPayment(form.dataset.paymentIntentId, data)
    .then(result => {
      var cardError = document.getElementById('card-errors')

      if (result.error) {
        cardError.textContent = result.error.message
      } else {
        form.submit()
      }
    })
  })
})

document.addEventListener("turbolinks:load", () => {
  let cardElement = document.querySelector("#card-element")

  if (cardElement !== null) { setupStripe() }

  let newCard = document.querySelector("#use-new-card")
  if (newCard !== null) {
    newCard.addEventListener("click", (event) => {
      event.preventDefault()
      document.querySelector("#payment-form").classList.remove("d-none")
      document.querySelector("#existing-card").classList.add("d-none")
    })
  }
})

function setupStripe() {
  const stripe_key = document.querySelector("meta[name='stripe-key']").getAttribute("content")
  const stripe = Stripe(stripe_key)

  const elements = stripe.elements()
  const card = elements.create('card')
  card.mount('#card-element')

  var displayError = document.getElementById('card-errors')

  card.addEventListener('change', (event) => {
    if (event.error) {
      displayError.textContent = event.error.message
    } else {
      displayError.textContent = ''
    }
  })

  const form = document.querySelector("#subscription-form")
  let paymentIntentId = form.dataset.paymentIntent
  let setupIntentId = form.dataset.setupIntent

  if (paymentIntentId) {
    if (form.dataset.status == "requires_action") {
      stripe.confirmCardPayment(paymentIntentId, { setup_future_usage: 'off_session' }).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
          form.querySelector("#card-details").classList.remove("d-none")
        } else {
          form.submit()
        }
      })
    }
  }

  form.addEventListener('submit', (event) => {
    event.preventDefault()

    let name = form.querySelector("#name_on_card").value
    let data = {
      payment_method_data: {
        card: card,
        billing_details: {
          name: name,
        }
      }
    }

    // Complete a payment intent
    if (paymentIntentId) {
      stripe.confirmCardPayment(paymentIntentId, {
        payment_method: data.payment_method_data,
        setup_future_usage: 'off_session',
        save_payment_method: true,
      }).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
          form.querySelector("#card-details").classList.remove("d-none")
        } else {
          form.submit()
        }
      })

    // Updating a card or subscribing with a trial (using a SetupIntent)
    } else if (setupIntentId) {
      stripe.confirmCardSetup(setupIntentId, {
        payment_method: data.payment_method_data
      }).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
        } else {
          addHiddenField(form, "payment_method_id", result.setupIntent.payment_method)
          form.submit()
        }
      })

    } else {
      // Subscribing with no trial
      data.payment_method_data.type = 'card'
      stripe.createPaymentMethod(data.payment_method_data).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
        } else {
          addHiddenField(form, "payment_method_id", result.paymentMethod.id)
          form.submit()
        }
      })
    }
  })
}

function addHiddenField(form, name, value) {
  let input = document.createElement("input")
  input.setAttribute("type", "hidden")
  input.setAttribute("name", name)
  input.setAttribute("value", value)
  form.appendChild(input)
}
