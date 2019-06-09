Rails.application.routes.draw do
  get    'tasks/index'
  get    'tasks/:id/edit'   => 'tasks#edit',   as: "task_edit"
  post   'tasks/:id/update' => 'tasks#update', as: "task_update"
  delete 'tasks/:id/delete' => 'tasks#delete', as: "task_delete"
  post   'line/bot'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
