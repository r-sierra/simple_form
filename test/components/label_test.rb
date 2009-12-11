require 'test_helper'

class LabelTest < ActionView::TestCase

  setup do
    SimpleForm::Components::Label.reset_i18n_cache :translate_required_html
  end

  def with_label_for(object, attribute, type, options={})
    simple_form_for object do |f|
      f.attribute  = attribute
      f.input_type = type
      f.options    = options

      label = SimpleForm::Components::Label.new(f, SimpleForm.terminator)
      concat(label.call)
      yield label if block_given?
    end
  end

  test 'label should not be generated for hidden inputs' do
    with_label_for @user, :name, :hidden do |label|
      assert label.call.blank?
    end
  end

  test 'label should generate a default humanized description' do
    with_label_for @user, :name, :string
    assert_select 'label[for=user_name]', /Name/
  end

  test 'label should allow a customized description' do
    with_label_for @user, :name, :string, :label => 'My label!'
    assert_select 'label[for=user_name]', /My label!/
  end

  test 'label should use human attribute name from object when available' do
    with_label_for @user, :description, :text
    assert_select 'label[for=user_description]', /User Description!/
  end

  test 'label should use i18n based on model, action, and attribute to lookup translation' do
    store_translations(:en, :simple_form => { :labels => { :user => {
      :new => { :description => 'Nova descrição' }
    } } } ) do
      params.merge!(:action => 'new')
      with_label_for @user, :description, :text
      assert_select 'label[for=user_description]', /Nova descrição/
    end
  end

  test 'label should use i18n based on model and attribute to lookup translation' do
    store_translations(:en, :simple_form => { :labels => { :user => {
      :description => 'Descrição'
    } } } ) do
      with_label_for @user, :description, :text
      assert_select 'label[for=user_description]', /Descrição/
    end
  end

  test 'input should use i18n based only on attribute to lookup translation' do
    store_translations(:en, :simple_form => { :labels => { :age => 'Idade' } } ) do
      with_label_for @user, :age, :integer
      assert_select 'label[for=user_age]', /Idade/
    end
  end

  test 'label should have css class from type' do
    with_label_for @user, :name, :string
    assert_select 'label.string'
    with_label_for @user, :description, :text
    assert_select 'label.text'
    with_label_for @user, :age, :integer
    assert_select 'label.integer'
    with_label_for @user, :born_at, :date
    assert_select 'label.date'
    with_label_for @user, :created_at, :datetime
    assert_select 'label.datetime'
  end

  test 'label should be required by default' do
    with_label_for @user, :name, :string
    assert_select 'label.required'
  end

  test 'label should be able to disable required' do
    with_label_for @user, :name, :string, :required => false
    assert_no_select 'label.required'
  end

  test 'label should add required text when required' do
    with_label_for @user, :name, :string
    assert_select 'label.required abbr[title=required]', '*'
  end

  test 'label should not have required text in no required inputs' do
    with_label_for @user, :name, :string, :required => false
    assert_no_select 'form label abbr'
  end

  test 'label should use i18n to find required text' do
    store_translations(:en, :simple_form => { :required => { :text => 'campo requerido' }}) do
      with_label_for @user, :name, :string
      assert_select 'form label abbr[title=campo requerido]', '*'
    end
  end

  test 'label should use i18n to find required mark' do
    store_translations(:en, :simple_form => { :required => { :mark => '*-*' }}) do
      with_label_for @user, :name, :string
      assert_select 'form label abbr', '*-*'
    end
  end

  test 'label should use i18n to find required string tag' do
    store_translations(:en, :simple_form => { :required => { :html => '<span class="required" title="requerido">*</span>' }}) do
      with_label_for @user, :name, :string
      assert_no_select 'form label abbr'
      assert_select 'form label span.required[title=requerido]', '*'
    end
  end

  test 'label should allow overwriting input id' do
    with_label_for @user, :name, :string, :input_html => { :id => 'my_new_id' }
    assert_select 'label[for=my_new_id]'
  end

  test 'label should use default input id when it was not overridden' do
    with_label_for @user, :name, :string, :input_html => { :class => 'my_new_id' }
    assert_select 'label[for=user_name]'
  end

  test 'label should be generated properly when object is not present' do
    with_label_for :project, :name, :string
    assert_select 'label[for=project_name]', /Name/
  end

  test 'label should use i18n properly when object is not present' do
    store_translations(:en, :simple_form => { :labels => {
      :project => { :name => 'Nome' }
    } } ) do
      with_label_for :project, :name, :string
      assert_select 'label[for=project_name]', /Nome/
    end
  end

  test 'label should add required by default when object is not present' do
    with_label_for :project, :name, :string
    assert_select 'label.required[for=project_name]'
    with_label_for :project, :description, :string, :required => false
    assert_no_select 'label.required[for=project_description]'
  end

  test 'label should point to first option when date input type' do
    with_label_for :project, :created_at, :date
    assert_select 'label[for=project_created_at_1i]'
  end

  test 'label should point to first option when datetime input type' do
    with_label_for :project, :created_at, :datetime
    assert_select 'label[for=project_created_at_1i]'
  end

  test 'label should point to first option when time input type' do
    with_label_for :project, :created_at, :time
    assert_select 'label[for=project_created_at_4i]'
  end
end