<tr id="datarow-{{.id}}" class="border-b dark:border-neutral-500">
  <td class="whitespace-nowrap px-6 py-4">{{.id}}</td>
  <td class="whitespace-nowrap px-6 py-4">
    <input
      type="text"
      class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
      data-include-edit="{{.id}}"
      name="company"
      value="{{.company}}"
    />
  </td>
  <td class="whitespace-nowrap px-6 py-4">
    <input
      type="text"
      class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
      data-include-edit="{{.id}}"
      name="contact"
      value="{{.contact}}"
    />
  </td>
  <td class="whitespace-nowrap px-6 py-4">
    <input
      type="text"
      class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
      data-include-edit="{{.id}}"
      name="country"
      value="{{.country}}"
    />
  </td>
  <td class="whitespace-nowrap px-1 py-1">
    <a
      hx-put="/company/{{.id}}"
      hx-target="#datarow-{{.id}}"
      hx-swap="outerHTML"
      hx-indicator="#processing"
      hx-include="input[data-include-edit='{{.id}}']"
      class="inline-flex items-center h-8 px-4 m-2 text-sm text-blue-100 transition-colors duration-150 bg-blue-700 rounded-lg focus:shadow-outline hover:bg-blue-800"
      href=""
      >Save</a
    >
  </td>
  <td class="whitespace-nowrap px-1 py-1">
    <a
      hx-get="/company/{{.id}}"
      hx-target="#datarow-{{.id}}"
      hx-swap="outerHTML"
      hx-indicator="#processing"
      class="inline-flex items-center h-8 px-4 m-2 text-sm text-red-100 transition-colors duration-150 bg-red-700 rounded-lg focus:shadow-outline hover:bg-red-800"
      href=""
      >Cancel</a
    >
  </td>
</tr>
