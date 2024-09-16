<div id="companies">
  <div id="processing" class="htmx-indicator">Processing...</div>
  <div class="flex flex-col">
    <div class="overflow-x-auto sm:-mx-6 lg:-mx-8">
      <div class="inline-block min-w-full py-2 sm:px-6 lg:px-8">
        <div class="overflow-hidden">
          <div class="flex justify-end">
            <button
              hx-get="/company/add"
              hx-target="#table-body"
              hx-swap="outerHTML"
              hx-indicator="#processing"
              class="inline-flex items-center h-8 px-4 m-2 text-sm text-blue-100 transition-colors duration-150 bg-blue-700 rounded-lg focus:shadow-outline hover:bg-blue-800"
              href=""
            >
              Add
            </button>
          </div>
          <table class="min-w-full text-left text-sm font-light">
            <thead class="border-b font-medium dark:border-neutral-500">
              <tr>
                <th scope="col" class="px-6 py-4">#</th>
                <th scope="col" class="px-6 py-4">Company</th>
                <th scope="col" class="px-6 py-4">Contact</th>
                <th scope="col" class="px-6 py-4">Country</th>
              </tr>
            </thead>
            <tbody id="table-body">
              {{ zmpl.content }}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
