# encoding: utf-8

module CallControllerTestHelpers
  def self.included(test_case)
    test_case.let(:call_id)     { new_uuid }
    test_case.let(:call)        { Adhearsion::Call.new }
    test_case.let(:block)       { nil }
    test_case.let(:metadata)    { {doo: :dah} }
    test_case.let(:controller)  { new_controller test_case.described_class }

    test_case.subject { controller }

    test_case.before do
      allow(call.wrapped_object).to receive_messages :write_command => true, :id => call_id
    end
  end

  def new_controller(target = nil)
    case target
    when Class
      raise "Your described class should inherit from Adhearsion::CallController" unless target.ancestors.include?(Adhearsion::CallController)
      target
    when Module, nil
      Class.new Adhearsion::CallController
    end.new call, metadata, &block
  end

  def expect_message_waiting_for_response(message = nil, fail = false, &block)
    expectation = expect(controller).to receive(:write_and_await_response, &block).once
    expectation = expectation.with message if message
    if fail
      expectation.and_raise fail
    else
      expectation.and_return message
    end
  end

  def expect_message_of_type_waiting_for_response(message)
    expect(controller).to receive(:write_and_await_response).once.with(kind_of(message.class)).and_return message
  end

  def expect_component_execution(component, fail = false)
    expectation = expect(controller).to receive(:execute_component_and_await_completion).once.with(component)
    if fail
      expectation.and_raise fail
    else
      expectation.and_return component
    end
    expectation
  end

  def expect_input_component_complete_event(utterance)
    complete_event = Adhearsion::Event::Complete.new
    allow(complete_event).to receive_messages reason: double(utterance: utterance, name: :input)
    allow_any_instance_of(Adhearsion::Rayo::Component::Input).to receive_messages(complete?: true, complete_event: complete_event)
  end
end
