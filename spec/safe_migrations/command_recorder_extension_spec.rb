# frozen_string_literal: true

RSpec.describe SafeMigrations::CommandRecorderExtension do
  subject(:recorder) { ActiveRecord::Migration::CommandRecorder.new }

  it 'swaps column names when reversing a rename' do
    expect(recorder.inverse_of(:safe_rename_column, %i[users old_name new_name]))
      .to eq([:safe_rename_column, %i[users new_name old_name]])
  end

  it 'negates nullability when reversing a null constraint' do
    expect(recorder.inverse_of(:safe_change_column_null, [:users, :name, false]))
      .to eq([:safe_change_column_null, [:users, :name, true]])
  end

  it 'swaps defaults when reversing a default change' do
    expect(recorder.inverse_of(:safe_change_column_default, [:users, :role, { from: 'guest', to: 'admin' }]))
      .to eq([:safe_change_column_default, [:users, :role, { from: 'admin', to: 'guest' }]])
  end
end
