describe 'Feature: Subscriber', ->

  describe 'AJAX subscriber from', ->

    before ->
      @Stubs = require '../stubs/stubs'

    beforeEach ->
      @formOptions =
        form           : new @Stubs.FormMock
        emailSelector  : 'input[name="email"]'
        submitSelector : 'input[type="submit"]'
      @subscriber = new window.DasSubscriber(@formOptions)

    it 'listens for form submits', ->
      sinon.spy(@formOptions.form, 'addEventListener')
      _subscriber = new window.DasSubscriber(@formOptions)
      expect(_subscriber.form.addEventListener.calledWith("submit"))
        .to.be true

    it 'serializes text and hidden data in the form', ->
      @formOptions.form.elements = [
        new @Stubs.DomNodeMock
          value : 'input value'
          name  : 'input'
        new @Stubs.DomNodeMock
          value : 'other input value'
          name  : 'other-input'
        new @Stubs.DomNodeMock
          value : 'hidden array value'
          name  : 'hidden-array-element[]'
        new @Stubs.DomNodeMock
          value : 'other hidden array value'
          name  : 'hidden-array-element[]'
      ]
      _subscriber = new window.DasSubscriber(@formOptions)

      _subscriber.submit()
      expect(_subscriber.carrier.params.length).to.be.above(@formOptions.form.elements.length)

    it 'sends the form data to a handler URL', ->
      expectation              = 'http://countryoutfitter.com/subscribe/'
      @formOptions.form.action = expectation
      _subscriber              = new window.DasSubscriber(@formOptions)

      _subscriber.submit()
      expect(_subscriber.carrier.carrier.src).to.contain expectation

    it 'will not submit an invalid email', ->
      @formOptions.emailSelector = 'input[name="invalid-email"]'
      _subscriber               = new window.DasSubscriber(@formOptions)

      sinon.spy(_subscriber, 'submit')

      _subscriber.handleFormSubmit(new @Stubs.EventMock)
      expect(_subscriber.submit.called).to.be false

    it 'calls a callback on form submit', ->
      sinon.spy(@subscriber, 'onsubmit')
      @subscriber.handleFormSubmit(new @Stubs.EventMock())
      expect(@subscriber.onsubmit.called).to.be true

    it 'calls a callback on error', ->
      @formOptions.emailSelector = 'input[name="invalid-email"]'
      _subscriber               = new window.DasSubscriber(@formOptions)

      sinon.spy(_subscriber, 'onerror')

      _subscriber.handleFormSubmit(new @Stubs.EventMock)
      expect(_subscriber.onerror.called).to.be true

    it 'sets a JSONP callback to be called on completion', ->
      sinon.spy(@subscriber, 'oncomplete')

      @subscriber.submit()

      callbackHandle = @subscriber.carrier.jsonpHandle
      expect(window).to.have.property(callbackHandle)

    it 'indicates status on form submit', ->
      @subscriber.handleFormSubmit(new @Stubs.EventMock)
      expect(@subscriber.form.className).to.contain(@subscriber.loadingClassName)

    it 'indicates status on error', ->
      @subscriber.handleError()
      expect(@subscriber.form.className).to.contain(@subscriber.errorClassName)

    it 'indicates status on completion', ->
      @subscriber.handleComplete()
      expect(@subscriber.form.className).to.contain(@subscriber.completeClassName)
