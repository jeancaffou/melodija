<template>
  <q-layout view="hHh lpR fFf" :class="['melodija-app', theme]">
    <q-header v-if="theme === 'modern' && !introVisible" class="modern-header">
      <q-toolbar>
        <q-toolbar-title class="modern-title">
          <img class="modern-title-icon" :src="melodijaIconUrl" alt="" />
          <span>Melodija</span>
        </q-toolbar-title>
        <q-badge class="modern-song-count" outline color="cyan-2">{{ counts.songs }} skladb</q-badge>
        <q-select
          class="modern-quick-jump"
          v-model="quickJump"
          dense
          outlined
          clearable
          use-input
          input-debounce="200"
          :options="quickJumpOptions"
          option-label="label"
          label="Hiter skok"
          @filter="filterQuickJump"
          @update:model-value="openQuickJump"
        >
          <template #prepend><q-icon name="search" /></template>
          <template #option="scope">
            <q-item v-bind="scope.itemProps">
              <q-item-section>
                <q-item-label>{{ scope.opt.label }}</q-item-label>
                <q-item-label caption>{{ scope.opt.detail }}</q-item-label>
              </q-item-section>
              <q-item-section side>{{ scope.opt.typeLabel }}</q-item-section>
            </q-item>
          </template>
        </q-select>
        <q-btn
          class="modern-mode-indicator"
          flat
          dense
          :icon="entryModeIcon"
          :title="entryModeLabel"
          :aria-label="entryModeLabel"
          @click="toggleEntryMode"
        />
        <q-btn flat dense :icon="themeIcon" @click="toggleTheme" />
        <q-btn class="modern-logout" flat dense icon="logout" label="Odjava" no-caps @click="logout" />
      </q-toolbar>
    </q-header>

    <q-page-container>
      <q-page class="app-page" tabindex="0">
        <section v-if="loading" class="dos-shell intro-mode">
          <dos-splash :interactive="false" />
          <div class="splash-loading-panel" role="status" aria-live="polite">
            <span>{{ APP_LOADING_MESSAGE }}</span><span class="dos-loading-cursor" aria-hidden="true">█</span>
          </div>
        </section>

        <template v-else>
          <section v-if="introVisible" class="dos-shell intro-mode" @click.self="enterCatalogMode">
            <dos-splash :interactive="false" @click="enterCatalogMode" />
            <div class="splash-entry-panel" @click.stop>
              <button class="splash-entry-button" @click="enterCatalogMode">Pregled kataloga</button>
              <button class="splash-entry-button" @click="requestEditorMode">Urejevalni način</button>
            </div>
          </section>

          <template v-else>
          <section v-if="theme === 'modern'" class="modern-shell">
            <aside class="modern-nav">
              <q-btn
                v-for="item in flatViews"
                :key="item.view"
                :class="{ active: activeView === item.view }"
                align="left"
                flat
                no-caps
                :icon="item.icon"
                :label="item.label"
                @click="openView(item.view)"
              />
            </aside>

            <main class="modern-main">
              <div v-if="isReadOnly" class="sheet-music-notice">
                Za notno gradivo pišite na <a href="mailto:dusan@kafol.net">dusan@kafol.net</a> ter navedite ime skladbe in opombo.
              </div>
              <div v-if="showModernActions" :class="['modern-actions', modernActionClass]">
                <q-input
                  v-if="showModernSearch"
                  ref="searchInput"
                  v-model="query"
                  dense
                  outlined
                  clearable
                  debounce="250"
                  :label="searchLabel"
                  @update:model-value="refreshActiveFromStart"
                >
                  <template #prepend><q-icon name="search" /></template>
                </q-input>
                <q-input
                  v-if="activeView === 'notes'"
                  v-model="noteSearch"
                  dense
                  outlined
                  clearable
                  debounce="250"
                  label="Išči opombo"
                  @update:model-value="refreshNotes"
                >
                  <template #prepend><q-icon name="search" /></template>
                </q-input>
                <q-select
                  v-if="activeView === 'songs'"
                  v-model="choirFilter"
                  dense
                  outlined
                  emit-value
                  map-options
                  :options="choirOptions"
                  label="Zbor"
                  clearable
                  @update:model-value="normalizeChoirFilter"
                />
                <q-select
                  v-if="activeView === 'songs'"
                  v-model="songArrangerFilter"
                  dense
                  outlined
                  clearable
                  use-input
                  input-debounce="250"
                  emit-value
                  map-options
                  :options="authorOptions"
                  label="Avtor"
                  @filter="filterAuthors"
                  @update:model-value="refreshSongsFromRoleFilter"
                />
                <q-select
                  v-if="activeView === 'songs'"
                  v-model="songLyricistFilter"
                  dense
                  outlined
                  clearable
                  use-input
                  input-debounce="250"
                  emit-value
                  map-options
                  :options="authorOptions"
                  label="Pesnik"
                  @filter="filterAuthors"
                  @update:model-value="refreshSongsFromRoleFilter"
                />
                <q-select
                  v-if="activeView === 'songs'"
                  v-model="noteFilter"
                  dense
                  outlined
                  clearable
                  use-input
                  input-debounce="250"
                  emit-value
                  map-options
                  :options="noteOptions"
                  label="Opomba"
                  @filter="filterNotes"
                  @update:model-value="refreshActiveFromStart"
                />
                <q-btn
                  v-if="activeView === 'songs'"
                  flat
                  icon="filter_alt_off"
                  label="Počisti filtre"
                  no-caps
                  :disable="!hasSongFilters"
                  @click="clearSongFilters"
                />
                <q-btn color="primary" icon="add" label="Nov zapis" no-caps :disable="isReadOnly" @click="newRecord" />
              </div>

              <div v-if="activeView === 'songs'" :class="['modern-grid', { 'no-editor': !selectedRows[0] }]">
                <q-table
                  class="catalog-table"
                  flat
                  bordered
                  dense
                  :rows="songs"
                  :columns="songColumns"
                  row-key="ownkey"
                  selection="single"
                  v-model:selected="selectedRows"
                  :pagination="{ rowsPerPage: 18 }"
                  @row-click="(_, row) => editSong(row)"
                >
                  <template #body-cell-arrangerName="scope">
                    <q-td :props="scope">
                      <button
                        v-if="scope.row.arrangerId"
                        class="table-link author-link"
                        @click.stop="filterSongsByArranger(scope.row.arrangerId)"
                      >
                        {{ scope.row.arrangerName || scope.row.arrangerId }}
                      </button>
                    </q-td>
                  </template>
                  <template #body-cell-lyricistName="scope">
                    <q-td :props="scope">
                      <button
                        v-if="scope.row.lyricistId"
                        class="table-link lyricist-link"
                        @click.stop="filterSongsByLyricist(scope.row.lyricistId)"
                      >
                        {{ scope.row.lyricistName || scope.row.lyricistId }}
                      </button>
                    </q-td>
                  </template>
                  <template #body-cell-note="scope">
                    <q-td :props="scope">
                      <button v-if="scope.row.note" class="table-link note-link" @click.stop="filterSongsByNote(scope.row.note)">
                        {{ scope.row.note }}
                      </button>
                    </q-td>
                  </template>
                </q-table>
                <article v-if="selectedRows[0]" class="editor-panel modern-editor-sidebar">
                  <div class="panel-title">Uredi podatke</div>
                  <q-btn class="editor-close" flat dense round icon="close" aria-label="Zapri urejanje" @click="closeSongEditor" />
                  <SongForm
                    :form="songForm"
                    :choir-options="choirOptions.slice(1)"
                    :author-options="authorOptions"
                    :readonly="isReadOnly"
                    @filter-authors="filterAuthors"
                    @save="saveSong"
                    @delete="removeSong"
                  />
                  <div v-if="selectedRows[0]" class="context-panel">
                    <div v-if="songForm.note" class="location-card">
                      <div class="location-label">Opomba</div>
                      <button class="location-value" @click="filterSongsByNote(songForm.note)">{{ songForm.note }}</button>
                    </div>
                    <div class="context-title">Povezave</div>
                    <div class="context-chips">
                      <q-chip clickable dense icon="view_list" color="teal-1" text-color="teal-10" @click="filterSongsByChoir(songForm.choirId)">
                        {{ selectedRows[0].choirName || selectedRows[0].choirShort || songForm.choirId }}
                      </q-chip>
                      <q-chip
                        v-if="songForm.arrangerId"
                        clickable
                        dense
                        icon="person"
                        color="pink-1"
                        text-color="pink-10"
                        @click="openAuthorById(songForm.arrangerId)"
                      >
                        {{ selectedRows[0].arrangerName || songForm.arrangerId }}
                      </q-chip>
                      <q-chip
                        v-if="songForm.lyricistId"
                        clickable
                        dense
                        icon="edit_note"
                        color="cyan-1"
                        text-color="cyan-10"
                        @click="openAuthorById(songForm.lyricistId)"
                      >
                        {{ selectedRows[0].lyricistName || songForm.lyricistId }}
                      </q-chip>
                      <q-chip
                        v-if="songForm.note"
                        clickable
                        dense
                        icon="inventory_2"
                        color="amber-1"
                        text-color="amber-10"
                        @click="filterSongsByNote(songForm.note)"
                      >
                        {{ songForm.note }}
                      </q-chip>
                    </div>
                    <div class="context-actions">
                      <q-btn dense flat no-caps icon="filter_alt" label="Skladbe zbora" @click="filterSongsByChoir(songForm.choirId)" />
                      <q-btn v-if="songForm.arrangerId" dense flat no-caps icon="music_note" label="Isti avtor" @click="filterSongsByArranger(songForm.arrangerId)" />
                      <q-btn v-if="songForm.lyricistId" dense flat no-caps icon="subject" label="Isti pesnik" @click="filterSongsByLyricist(songForm.lyricistId)" />
                      <q-btn v-if="songForm.note" dense flat no-caps icon="inventory_2" label="Ista opomba" @click="filterSongsByNote(songForm.note)" />
                    </div>
                    <div v-if="songContext.note.length" class="relation-block location-relations">
                      <div class="relation-heading">Ista opomba <span>{{ songContext.noteTotal }}</span></div>
                      <button v-for="row in songContext.note" :key="`note-${row.ownkey}`" class="relation-row" @click="focusSong(row)">
                        <span class="relation-code">{{ songCode(row) }}</span>
                        <span class="relation-name">{{ row.title }}</span>
                      </button>
                    </div>
                  </div>
                </article>
              </div>

              <div v-else-if="activeView === 'authors'" :class="['modern-grid', { 'no-editor': !selectedAuthorRows[0] }]">
                <q-table
                  class="catalog-table"
                  flat
                  bordered
                  dense
                  :rows="authors"
                  :columns="authorColumns"
                  row-key="id"
                  selection="single"
                  v-model:selected="selectedAuthorRows"
                  :pagination="{ rowsPerPage: 18 }"
                  @row-click="(_, row) => toggleAuthorEditor(row)"
                />
                <article v-if="selectedAuthorRows[0]" class="editor-panel modern-editor-sidebar">
                  <div class="panel-title">Uredi podatke</div>
                  <q-btn class="editor-close" flat dense round icon="close" aria-label="Zapri urejanje" @click="closeAuthorEditor" />
                  <q-input v-model.number="authorForm.id" dense outlined label="Šifra" type="number" :disable="isReadOnly" />
                  <q-input v-model="authorForm.name" dense outlined label="Naziv" :disable="isReadOnly" />
                  <q-select
                    v-model.number="authorForm.type"
                    dense
                    outlined
                    emit-value
                    map-options
                    :options="authorTypeOptions"
                    label="Vrsta"
                    :disable="isReadOnly"
                  />
                  <q-btn color="primary" icon="save" label="Shrani" no-caps :disable="isReadOnly" @click="saveAuthor" />
                  <q-btn flat color="negative" icon="delete" label="Briši" no-caps :disable="isReadOnly" @click="removeAuthor" />
                  <div v-if="authorForm.id" class="context-panel">
                    <div class="context-title">Povezave</div>
                    <div class="context-actions">
                      <q-btn dense flat no-caps icon="music_note" label="Kot avtor" @click="filterSongsByArranger(authorForm.id)" />
                      <q-btn dense flat no-caps icon="subject" label="Kot pesnik" @click="filterSongsByLyricist(authorForm.id)" />
                    </div>
                    <div v-if="authorContext.arranged.length" class="relation-block">
                      <div class="relation-heading">Kot avtor glasbe <span>{{ authorContext.arrangedTotal }}</span></div>
                      <button v-for="row in authorContext.arranged" :key="`author-arr-${row.ownkey}`" class="relation-row" @click="focusSong(row)">
                        <span class="relation-code">{{ songCode(row) }}</span>
                        <span class="relation-name">{{ row.title }}</span>
                      </button>
                    </div>
                    <div v-if="authorContext.lyricist.length" class="relation-block">
                      <div class="relation-heading">Kot pesnik <span>{{ authorContext.lyricistTotal }}</span></div>
                      <button v-for="row in authorContext.lyricist" :key="`author-lyr-${row.ownkey}`" class="relation-row" @click="focusSong(row)">
                        <span class="relation-code">{{ songCode(row) }}</span>
                        <span class="relation-name">{{ row.title }}</span>
                      </button>
                    </div>
                  </div>
                </article>
              </div>

              <div v-else-if="activeView === 'choirs'" :class="['modern-grid', { 'no-editor': !selectedChoirRows[0] }]">
                <q-table
                  class="catalog-table"
                  flat
                  bordered
                  dense
                  :rows="choirs"
                  :columns="choirColumns"
                  row-key="id"
                  selection="single"
                  v-model:selected="selectedChoirRows"
                  :pagination="{ rowsPerPage: 18 }"
                  @row-click="(_, row) => editChoir(row)"
                />
                <article v-if="selectedChoirRows[0]" class="editor-panel modern-editor-sidebar">
                  <div class="panel-title">Uredi podatke</div>
                  <q-btn class="editor-close" flat dense round icon="close" aria-label="Zapri urejanje" @click="closeChoirEditor" />
                  <q-input v-model.number="choirForm.id" dense outlined label="Šifra" type="number" :disable="isReadOnly" />
                  <q-input v-model="choirForm.name" dense outlined label="Naziv" :disable="isReadOnly" />
                  <q-input v-model="choirForm.shortName" dense outlined label="Kratek naziv" :disable="isReadOnly" />
                  <q-btn color="primary" icon="save" label="Shrani" no-caps :disable="isReadOnly" @click="saveChoir" />
                  <q-btn flat color="negative" icon="delete" label="Briši" no-caps :disable="isReadOnly" @click="removeChoir" />
                  <div v-if="choirForm.id" class="context-panel">
                    <div class="context-title">Povezave</div>
                    <div class="context-actions">
                      <q-btn dense flat no-caps icon="filter_alt" label="Skladbe zbora" @click="filterSongsByChoir(choirForm.id)" />
                    </div>
                    <div v-if="choirContext.songs.length" class="relation-block">
                      <div class="relation-heading">Skladbe <span>{{ choirContext.total }}</span></div>
                      <button v-for="row in choirContext.songs" :key="`choir-song-${row.ownkey}`" class="relation-row" @click="focusSong(row)">
                        <span class="relation-code">{{ songCode(row) }}</span>
                        <span class="relation-name">{{ row.title }}</span>
                      </button>
                    </div>
                  </div>
                </article>
              </div>

              <div v-else-if="activeView === 'notes'" class="report-layout">
                <article class="editor-panel report-options">
                  <div class="panel-title">Opombe</div>
                  <div v-if="selectedNoteRows[0]" class="location-card">
                    <div class="location-label">Opomba</div>
                    <button class="location-value" @click="filterSongsByNote(selectedNoteRows[0].note)">{{ selectedNoteRows[0].note }}</button>
                    <div class="stat-line">{{ selectedNoteRows[0].count }} skladb</div>
                  </div>
                  <q-btn color="primary" icon="library_music" label="Prikaži skladbe" no-caps :disable="!selectedNoteRows[0]" @click="filterSongsByNote(selectedNoteRows[0].note)" />
                </article>
                <q-table
                  class="catalog-table notes-table"
                  flat
                  bordered
                  dense
                  :rows="notes"
                  :columns="noteColumns"
                  row-key="note"
                  selection="single"
                  v-model:selected="selectedNoteRows"
                  :pagination="{ rowsPerPage: 50 }"
                  @row-click="(_, row) => editNote(row)"
                  @row-dblclick="(_, row) => filterSongsByNote(row.note)"
                >
                  <template #body-cell-note="scope">
                    <q-td :props="scope">
                      <button class="note-link" @click.stop="filterSongsByNote(scope.row.note)">
                        {{ scope.row.note }}
                      </button>
                    </q-td>
                  </template>
                </q-table>
              </div>

              <div v-else-if="activeView === 'reports'" class="report-layout">
                <article class="editor-panel report-options">
                  <div class="panel-title">Izpis</div>
                  <q-select v-model="reportType" dense outlined emit-value map-options :options="reportOptions" label="Vrsta" @update:model-value="reportOptionsChanged" />
                  <q-select v-model="reportOrder" dense outlined emit-value map-options :options="orderOptions" label="Ureditev" @update:model-value="generateReport" />
                  <q-select
                    v-if="showReportChoirFilter"
                    v-model="choirFilter"
                    dense
                    outlined
                    emit-value
                    map-options
                    :options="choirOptions"
                    label="Zbor"
                    clearable
                    @update:model-value="normalizeReportChoirFilter"
                  />
                  <q-select
                    v-if="showReportAuthorFilter"
                    v-model="reportAuthor"
                    dense
                    outlined
                    clearable
                    use-input
                    input-debounce="250"
                    emit-value
                    map-options
                    :options="authorOptions"
                    :label="reportAuthorLabel"
                    @filter="filterAuthors"
                    @update:model-value="generateReport"
                  />
                  <q-btn color="primary" icon="receipt_long" label="Prikaži" no-caps @click="generateReport" />
                  <q-btn class="print-button" flat icon="print" label="Tiskaj" no-caps @click="printReport" />
                  <q-input v-model="reportFilter" dense outlined label="Išči po izpisu" clearable>
                    <template #prepend><q-icon name="search" /></template>
                  </q-input>
                </article>
                <q-table
                  class="catalog-table report-table"
                  flat
                  bordered
                  dense
                  :rows="filteredReportRows"
                  :columns="reportColumns"
                  :row-key="reportRowKey"
                  :pagination="{ rowsPerPage: 50 }"
                  @row-click="(_, row) => openReportRow(row)"
                >
                  <template #body-cell-note="scope">
                    <q-td :props="scope">
                      <button v-if="scope.row.note" class="note-link" @click.stop="filterSongsByNote(scope.row.note)">
                        {{ scope.row.note }}
                      </button>
                    </q-td>
                  </template>
                </q-table>
                <section class="print-report" aria-hidden="true">
                  <h1>{{ reportPrintTitle }}</h1>
                  <div class="print-meta">{{ reportPrintMeta }}</div>
                  <table>
                    <thead>
                      <tr>
                        <th
                          v-for="column in reportColumns"
                          :key="column.name"
                          :class="`print-col-${column.name}`"
                        >
                          {{ column.label }}
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="row in filteredReportRows" :key="printReportRowKey(row)">
                        <td
                          v-for="column in reportColumns"
                          :key="column.name"
                          :class="`print-col-${column.name}`"
                        >
                          {{ reportCell(row, column) }}
                        </td>
                      </tr>
                      <tr v-if="!filteredReportRows.length">
                        <td :colspan="reportColumns.length">Ni podatkov za izpis.</td>
                      </tr>
                    </tbody>
                  </table>
                </section>
              </div>

              <div v-else-if="activeView === 'maintenance'" class="report-layout">
                <article class="editor-panel report-options">
                  <div class="panel-title">Vzdrževanje</div>
                  <div class="stat-line">SQLite: {{ dbPath }}</div>
                  <div class="stat-line">Kopije: {{ maintenanceBackups.length }}</div>
                  <q-btn color="primary" icon="save" label="Shranjevanje podatkov" no-caps :disable="isReadOnly" @click="runMaintenanceAction('backup')" />
                  <q-btn flat icon="download" label="Prenesi bazo" no-caps :disable="isReadOnly" @click="downloadDatabase" />
                  <q-btn flat icon="restore" label="Vračanje podatkov" no-caps :disable="isReadOnly" @click="runMaintenanceAction('restore')" />
                  <q-btn flat icon="sync" label="Rebuild" no-caps :disable="isReadOnly" @click="runMaintenanceAction('rebuild')" />
                  <q-input v-model="appDate" dense outlined label="Datum aplikacije" type="date" :disable="isReadOnly" />
                  <q-input v-model="appTime" dense outlined label="Ura aplikacije" type="time" :disable="isReadOnly" />
                  <q-btn flat icon="event" label="Shrani datum/uro" no-caps :disable="isReadOnly" @click="saveAppClock" />
                  <q-input v-model="operatorName" dense outlined label="Vnašalec" :disable="isReadOnly" />
                  <q-btn flat icon="person" label="Shrani vnašalca" no-caps :disable="isReadOnly" @click="saveOperator" />
                  <div v-if="maintenanceMessage" class="stat-line">{{ maintenanceMessage }}</div>
                </article>
                <pre class="report-preview">{{ maintenanceText }}</pre>
              </div>

              <div v-else-if="activeView === 'database'" class="report-layout database-layout">
                <article class="editor-panel report-options">
                  <div class="panel-title">Baza</div>
                  <div class="stat-line">SQLite: {{ dbPath }}</div>
                  <q-select
                    v-model="databaseTable"
                    dense
                    outlined
                    emit-value
                    map-options
                    :options="databaseTableOptions"
                    label="Tabela"
                    @update:model-value="selectDatabaseTable"
                  />
                  <q-input v-model="databaseFilter" dense outlined debounce="250" label="Išči po tabeli" clearable @update:model-value="refreshDatabaseFromStart">
                    <template #prepend><q-icon name="search" /></template>
                  </q-input>
                  <q-toggle v-model="databaseShowTechnical" dense label="Tehnična polja" @update:model-value="refreshDatabaseColumns" />
                  <q-btn color="primary" icon="refresh" label="Osveži" no-caps @click="refreshDatabase" />
                  <div class="stat-line">{{ databasePagination.rowsNumber }} vrstic</div>
                </article>
                <q-table
                  class="catalog-table database-table"
                  flat
                  bordered
                  dense
                  binary-state-sort
                  :rows="databaseRows"
                  :columns="databaseColumns"
                  :row-key="databaseRowKey"
                  :loading="databaseLoading"
                  v-model:pagination="databasePagination"
                  :rows-per-page-options="[25, 50, 100, 250]"
                  @request="requestDatabaseRows"
                />
              </div>
              <div v-if="dataLoading" class="data-loading-overlay modern-data-loader" role="status" aria-live="polite">
                <div class="data-loading-box">
                  <span class="data-loading-spinner" aria-hidden="true"></span>
                  <span>{{ dataLoadingMessage }}</span>
                </div>
              </div>
            </main>
          </section>

          <section v-else class="dos-shell">
              <div class="dos-top">
                <span>Copyright COMFIN</span>
                <span>{{ currentOperator }}</span>
                <span>{{ today }}</span>
              </div>
              <div class="dos-frame">
                <div class="dos-side">M<br />E<br />L<br />O<br />D<br />I<br />J<br />A</div>
                <div class="dos-work">
                  <div class="dos-menu-stack">
                    <div class="dos-menu primary">
                      <div class="dos-menu-title">OSNOVNI MENU</div>
                      <button
                        v-for="(item, index) in menuItems"
                        :key="item.label"
                        :class="{ selected: selectedMain === index }"
                        @click="selectMain(index, true)"
                        @dblclick="activateMain"
                      >
                        <span class="dos-marker">{{ selectedMain === index ? '►' : '░' }}</span>
                        {{ item.label }}
                      </button>
                    </div>
                    <div v-if="menuLevel === 'child' && currentChildren.length" class="dos-menu secondary">
                      <div class="dos-menu-title">{{ menuItems[selectedMain].label }}</div>
                      <button
                        v-for="(item, index) in currentChildren"
                        :key="item.label"
                        :class="{ selected: selectedChild === index }"
                        @click="selectChild(index); activateChild()"
                        @dblclick="activateChild"
                      >
                        <span class="dos-marker">{{ selectedChild === index ? '►' : '░' }}</span>
                        {{ item.label }}
                      </button>
                    </div>
                  </div>
                  <div v-if="servicePasswordVisible" class="dos-password-prompt">
                    <span>Geslo:</span>
                    <input
                      ref="servicePasswordInput"
                      v-model="servicePassword"
                      type="password"
                      maxlength="4"
                      @keydown.enter.prevent="submitServicePassword"
                      @keydown.esc.prevent="cancelServicePassword"
                    />
                  </div>
                  <div v-if="lookupVisible" class="dos-lookup">
                    <div class="dos-lookup-title">{{ lookupTitle }}</div>
                    <div class="dos-table-scroll">
                      <table class="dos-table">
                        <tbody>
                          <tr
                            v-for="(row, index) in visibleLookupRows"
                            :key="row.key"
                            :class="{ selected: lookupSelected === lookupOffset + index }"
                            @click="selectLookupRow(lookupOffset + index)"
                            @dblclick="applyLookupRow"
                          >
                            <td>{{ row.code }}</td>
                            <td>{{ row.name }}</td>
                            <td>{{ row.extra }}</td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <div v-if="dataLoading" class="dos-data-loader" role="status" aria-live="polite">
                    <span>{{ dataLoadingMessage }}</span><span class="dos-loading-cursor" aria-hidden="true">█</span>
                  </div>

                  <div v-if="activeView !== 'menu'" class="dos-panel">
                    <div class="dos-panel-title">{{ activeTitle }}</div>

                    <div v-if="activeView === 'songs'" class="dos-catalog">
                      <div class="dos-form-row">
                        <label>Išči :</label>
                        <input ref="dosSearchInput" v-model="query" />
                        <select v-model.number="choirFilter" data-dos-field="report.choir">
                          <option v-for="option in choirOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                        </select>
                        <button @click="showClassicSongs">Prikaži</button>
                      </div>
                      <div class="dos-table-scroll">
                        <table class="dos-table">
                          <thead>
                            <tr><th>Zbor</th><th>Šifra</th><th>Naziv</th><th>Avtor</th><th>Verz</th></tr>
                          </thead>
                          <tbody>
                            <tr
                              v-for="(song, index) in visibleDosSongs"
                              :key="song.ownkey"
                              :class="{ selected: selectedResult === dosOffset + index }"
                              @click="selectDosResult(dosOffset + index)"
                            >
                              <td>{{ song.choirShort }}</td>
                              <td>{{ song.number }}</td>
                              <td>{{ song.title }}</td>
                              <td>{{ song.arrangerName }}</td>
                              <td>{{ song.verse }}</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                      <div class="dos-edit-grid">
                        <label>Zbor :</label><input v-model.number="songForm.choirId" data-dos-field="song.choir" :disabled="isReadOnly" />
                        <label>Šifra :</label><input v-model.number="songForm.number" data-dos-field="song.number" :disabled="isReadOnly" />
                        <label>Naziv :</label><input v-model="songForm.title" data-dos-field="song.title" :disabled="isReadOnly" />
                        <label>Verz :</label><input class="dos-wide-field" v-model="songForm.verse" data-dos-field="song.verse" :disabled="isReadOnly" />
                        <label>Pesnik :</label><input v-model.number="songForm.lyricistId" data-dos-field="song.lyricist" :disabled="isReadOnly" />
                        <label>Avtor :</label><input v-model.number="songForm.arrangerId" data-dos-field="song.arranger" :disabled="isReadOnly" />
                        <label>Opomba :</label><input class="dos-wide-field" v-model="songForm.note" data-dos-field="song.note" :disabled="isReadOnly" />
                      </div>
                      <div class="dos-buttons">
                        <button :disabled="isReadOnly" @click="saveSong">Shrani</button>
                        <button :disabled="isReadOnly" @click="newSong">Nov</button>
                        <button :disabled="isReadOnly" @click="removeSong">Briši</button>
                      </div>
                    </div>

                    <div v-else-if="activeView === 'authors'" class="dos-catalog">
                      <div class="dos-form-row">
                        <label>Naziv :</label>
                        <input v-model="query" />
                        <button @click="showClassicAuthors">Prikaži</button>
                      </div>
                      <div class="dos-table-scroll">
                        <table class="dos-table narrow">
                          <tbody>
                            <tr
                              v-for="(author, index) in visibleDosAuthors"
                              :key="author.id"
                              :class="{ selected: selectedResult === dosOffset + index }"
                              @click="selectDosResult(dosOffset + index)"
                            >
                              <td>{{ author.id }}</td><td>{{ author.name }}</td><td>{{ author.type }}</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                      <div class="dos-edit-grid compact">
                        <label>Šifra :</label><input v-model.number="authorForm.id" data-dos-field="author.id" :disabled="isReadOnly" />
                        <label>Naziv :</label><input v-model="authorForm.name" data-dos-field="author.name" :disabled="isReadOnly" />
                        <label>Vrsta :</label><input v-model.number="authorForm.type" data-dos-field="author.type" :disabled="isReadOnly" />
                      </div>
                      <div class="dos-buttons">
                        <button :disabled="isReadOnly" @click="saveAuthor">Shrani</button>
                        <button :disabled="isReadOnly" @click="newAuthor">Nov</button>
                        <button :disabled="isReadOnly" @click="fillNextAuthorId">Naslednja</button>
                        <button :disabled="isReadOnly" @click="removeAuthor">Briši</button>
                      </div>
                    </div>

                    <div v-else-if="activeView === 'choirs'" class="dos-catalog">
                      <div class="dos-form-row single-action">
                        <label>Zbori :</label>
                        <button @click="showClassicChoirs">Prikaži</button>
                      </div>
                      <div class="dos-table-scroll">
                        <table class="dos-table narrow">
                          <tbody>
                            <tr
                              v-for="(choir, index) in visibleDosChoirs"
                              :key="choir.id"
                              :class="{ selected: selectedResult === dosOffset + index }"
                              @click="selectDosResult(dosOffset + index)"
                            >
                              <td>{{ choir.id }}</td><td>{{ choir.name }}</td><td>{{ choir.shortName }}</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                      <div class="dos-edit-grid compact">
                        <label>Šifra :</label><input v-model.number="choirForm.id" data-dos-field="choir.id" :disabled="isReadOnly" />
                        <label>Naziv :</label><input v-model="choirForm.name" data-dos-field="choir.name" :disabled="isReadOnly" />
                        <label>Kratko :</label><input v-model="choirForm.shortName" data-dos-field="choir.shortName" :disabled="isReadOnly" />
                      </div>
                      <div class="dos-buttons">
                        <button :disabled="isReadOnly" @click="saveChoir">Shrani</button>
                        <button :disabled="isReadOnly" @click="newChoir">Nov</button>
                        <button :disabled="isReadOnly" @click="fillNextChoirId">Naslednja</button>
                        <button :disabled="isReadOnly" @click="removeChoir">Briši</button>
                      </div>
                    </div>

                    <div v-else-if="activeView === 'reports'" class="dos-catalog">
                      <div class="dos-form-row">
                        <label>Izpis :</label>
                        <select v-model="reportType" @change="reportOptionsChanged">
                          <option v-for="option in reportOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                        </select>
                        <button @click="generateReport">Prikaži</button>
                      </div>
                      <div class="dos-form-row">
                        <label>Zbor :</label>
                        <select v-model.number="choirFilter" data-dos-field="report.choir">
                          <option v-for="option in choirOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                        </select>
                        <select v-model="reportOrder">
                          <option v-for="option in orderOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                        </select>
                      </div>
                      <div class="dos-form-row">
                        <label>{{ reportAuthorLabel }} :</label>
                        <input v-model="reportAuthor" data-dos-field="report.author" />
                        <button class="print-button" @click="printReport">Tiskaj</button>
                      </div>
                      <pre class="dos-report">{{ reportText }}</pre>
                      <section class="print-report" aria-hidden="true">
                        <h1>{{ reportPrintTitle }}</h1>
                        <div class="print-meta">{{ reportPrintMeta }}</div>
                        <table>
                          <thead>
                            <tr>
                              <th
                                v-for="column in reportColumns"
                                :key="column.name"
                                :class="`print-col-${column.name}`"
                              >
                                {{ column.label }}
                              </th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="row in filteredReportRows" :key="printReportRowKey(row)">
                              <td
                                v-for="column in reportColumns"
                                :key="column.name"
                                :class="`print-col-${column.name}`"
                              >
                                {{ reportCell(row, column) }}
                              </td>
                            </tr>
                            <tr v-if="!filteredReportRows.length">
                              <td :colspan="reportColumns.length">Ni podatkov za izpis.</td>
                            </tr>
                          </tbody>
                        </table>
                      </section>
                    </div>

                    <div v-else class="dos-catalog">
                      <div class="dos-maintenance">
                        <div>SQLite : {{ dbPath }}</div>
                        <div>Kopije : {{ maintenanceBackups.length }}</div>
                        <div v-if="maintenanceMessage">{{ maintenanceMessage }}</div>
                        <div class="dos-form-row">
                          <label>Datum :</label>
                          <input v-model="appDate" type="date" :disabled="isReadOnly" />
                        </div>
                        <div class="dos-form-row">
                          <label>Ura :</label>
                          <input v-model="appTime" type="time" :disabled="isReadOnly" />
                        </div>
                        <div class="dos-form-row">
                          <label>Vnašalec :</label>
                          <input v-model="operatorName" :disabled="isReadOnly" />
                        </div>
                      </div>
                      <div class="dos-buttons">
                        <button :disabled="isReadOnly" @click="runMaintenanceAction('backup')">Shrani</button>
                        <button :disabled="isReadOnly" @click="downloadDatabase">Prenesi bazo</button>
                        <button :disabled="isReadOnly" @click="runMaintenanceAction('restore')">Vrni</button>
                        <button :disabled="isReadOnly" @click="runMaintenanceAction('rebuild')">Rebuild</button>
                        <button :disabled="isReadOnly" @click="saveAppClock">Datum/Ura</button>
                        <button :disabled="isReadOnly" @click="saveOperator">Vnašalec</button>
                      </div>
	                    </div>
	                  </div>
	                  <div v-if="isReadOnly" class="dos-sheet-notice">
	                    Za notno gradivo pišite na dusan@kafol.net ter navedite ime skladbe in opombo.
	                  </div>
	                </div>
	              </div>
	              <div class="dos-status">{{ statusLine }}</div>
	          </section>
          </template>
        </template>

        <form v-if="entryPasswordVisible" class="splash-password-dialog" @submit.prevent="submitEditorPassword">
          <div class="splash-dialog-title">GESLO ZA UREJANJE</div>
          <label>
            <span>Geslo:</span>
            <input
              ref="entryPasswordInput"
              v-model="entryPassword"
              type="password"
              autocomplete="current-password"
              @keydown.esc.prevent="cancelEditorPassword"
            />
          </label>
          <div v-if="entryPasswordError" class="splash-dialog-error">{{ entryPasswordError }}</div>
          <div class="splash-dialog-actions">
            <button type="submit">Potrdi</button>
            <button type="button" @click="cancelEditorPassword">Preklic</button>
          </div>
        </form>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { computed, defineComponent, h, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue';
import { QBtn, QInput, QSelect, useQuasar } from 'quasar';
import { BookOpen, FileText, ListMusic, Monitor, Moon, PenLine, Search, Settings, Users } from 'lucide-vue-next';
import { api } from './services/api.js';
import DosSplash from './components/DosSplash.vue';
import melodijaIconUrl from '../../electron/assets/melodija.ico?url';

const $q = useQuasar();

const SongForm = defineComponent({
  name: 'SongForm',
  props: {
    form: { type: Object, required: true },
    choirOptions: { type: Array, required: true },
    authorOptions: { type: Array, required: true },
    readonly: { type: Boolean, default: false }
  },
  emits: ['filter-authors', 'save', 'delete'],
  setup(props, { emit }) {
    return () => h('div', { class: 'song-form' }, [
      h('div', { class: 'form-split' }, [
        h(QSelect, {
          modelValue: props.form.choirId,
          'onUpdate:modelValue': (value) => { props.form.choirId = value; },
          options: props.choirOptions,
          dense: true,
          outlined: true,
          emitValue: true,
          mapOptions: true,
          label: 'Zbor',
          disable: props.readonly
        }),
        h(QInput, {
          modelValue: props.form.number,
          'onUpdate:modelValue': (value) => { props.form.number = Number(value); },
          dense: true,
          outlined: true,
          type: 'number',
          label: 'Šifra',
          disable: props.readonly
        })
      ]),
      h(QInput, {
        modelValue: props.form.title,
        'onUpdate:modelValue': (value) => { props.form.title = value; },
        dense: true,
        outlined: true,
        label: 'Naziv',
        disable: props.readonly
      }),
      h(QInput, {
        modelValue: props.form.verse,
        'onUpdate:modelValue': (value) => { props.form.verse = value; },
        dense: true,
        outlined: true,
        label: 'Začetni verz',
        disable: props.readonly
      }),
      h(QSelect, {
        modelValue: props.form.arrangerId,
        'onUpdate:modelValue': (value) => { props.form.arrangerId = value || 0; },
        options: props.authorOptions,
        dense: true,
        outlined: true,
        clearable: true,
        useInput: true,
        emitValue: true,
        mapOptions: true,
        inputDebounce: 250,
        label: 'Avtor glasbe / priredbe',
        disable: props.readonly,
        onFilter: (value, update) => emit('filter-authors', value, update)
      }),
      h(QSelect, {
        modelValue: props.form.lyricistId,
        'onUpdate:modelValue': (value) => { props.form.lyricistId = value || 0; },
        options: props.authorOptions,
        dense: true,
        outlined: true,
        clearable: true,
        useInput: true,
        emitValue: true,
        mapOptions: true,
        inputDebounce: 250,
        label: 'Avtor besedila / osnova',
        disable: props.readonly,
        onFilter: (value, update) => emit('filter-authors', value, update)
      }),
      h(QInput, {
        modelValue: props.form.note,
        'onUpdate:modelValue': (value) => { props.form.note = value; },
        dense: true,
        outlined: true,
        autogrow: true,
        label: 'Opomba',
        disable: props.readonly
      }),
      h('div', { class: 'form-actions' }, [
        h(QBtn, { color: 'primary', icon: 'save', label: 'Shrani', noCaps: true, disable: props.readonly, onClick: () => emit('save') }),
        h(QBtn, { flat: true, color: 'negative', icon: 'delete', label: 'Briši', noCaps: true, disable: props.readonly, onClick: () => emit('delete') })
      ])
    ]);
  }
});

const APP_LOADING_MESSAGE = 'Nalagam...';
const DATA_LOADING_MESSAGE = 'Nalagam podatke...';

const loading = ref(true);
const theme = ref('dos');
const introVisible = ref(true);
const entryMode = ref('');
const entryPasswordVisible = ref(false);
const entryPassword = ref('');
const entryPasswordError = ref('');
const entryPasswordEnterAfterUnlock = ref(true);
const activeView = ref('menu');
const query = ref('');
const choirFilter = ref(0);
const songArrangerFilter = ref(null);
const songLyricistFilter = ref(null);
const noteFilter = ref(null);
const quickJump = ref(null);
const quickJumpOptions = ref([]);
const selectedMain = ref(0);
const selectedChild = ref(0);
const menuLevel = ref('main');
const selectedResult = ref(0);
const dosOffset = ref(0);
const servicePasswordVisible = ref(false);
const servicePassword = ref('');
const lookupVisible = ref(false);
const lookupTitle = ref('');
const lookupTarget = ref('');
const lookupRows = ref([]);
const lookupSelected = ref(0);
const lookupOffset = ref(0);
const selectedRows = ref([]);
const selectedAuthorRows = ref([]);
const selectedChoirRows = ref([]);
const selectedNoteRows = ref([]);
const songs = ref([]);
const authors = ref([]);
const choirs = ref([]);
const choirChoices = ref([]);
const notes = ref([]);
const databaseTables = ref([]);
const databaseTable = ref('songs');
const databaseRows = ref([]);
const databaseAllColumns = ref([]);
const databaseColumns = ref([]);
const databaseFilter = ref('');
const databaseShowTechnical = ref(false);
const databaseLoading = ref(false);
const dataLoadingCount = ref(0);
const dataLoadingMessage = ref(DATA_LOADING_MESSAGE);
const databasePagination = ref({
  sortBy: 'title',
  descending: false,
  page: 1,
  rowsPerPage: 50,
  rowsNumber: 0
});
const authorOptions = ref([]);
const noteOptions = ref([]);
const reportText = ref('');
const reportRows = ref([]);
const reportFilter = ref('');
const noteSearch = ref('');
const reportType = ref('songs');
const reportOrder = ref('alpha');
const reportAuthor = ref(null);
const songSort = ref('title');
const authorSort = ref('name');
const choirSort = ref('id');
const maintenanceBackups = ref([]);
const maintenanceMessage = ref('');
const appDate = ref('');
const appTime = ref('');
const operatorName = ref('dusan');
const dbPath = ref('');
const counts = reactive({ songs: 0, authors: 0, choirs: 0, corrections: 0, issues: 0 });

const songForm = reactive(emptySong());
const authorForm = reactive({ id: null, name: '', type: 1 });
const choirForm = reactive({ id: null, name: '', shortName: '' });
const songContext = reactive({
  sameChoir: [],
  sameChoirTotal: 0,
  arranger: [],
  arrangerTotal: 0,
  lyricist: [],
  lyricistTotal: 0,
  note: [],
  noteTotal: 0
});
const authorContext = reactive({ arranged: [], arrangedTotal: 0, lyricist: [], lyricistTotal: 0 });
const choirContext = reactive({ songs: [], total: 0 });
const searchInput = ref(null);
const dosSearchInput = ref(null);
const servicePasswordInput = ref(null);
const entryPasswordInput = ref(null);
let songContextRequest = 0;
let authorContextRequest = 0;
let choirContextRequest = 0;
let bootstrapPromise = null;

const ENTRY_MODE_KEY = 'melodija.entryMode';
const EDITOR_TOKEN_KEY = 'melodija.editorToken';
const EDITOR_PASSWORD_SALT = 'melodija-editor-auth-v1:2026-05-29';
const EDITOR_PASSWORD_TOKEN = 'dae9b02479c58ecf1922eb57c1431ea8f9f0ee2779b6f1381775efa6b02f045697cec3e33246bb4740b08c76a4069772d609dd7202b346f407bbba320433c193';

const menuItems = [
  {
    label: 'Osnovni podatki',
    children: [
      { label: 'Pesmi', view: 'songs', icon: 'library_music' },
      { label: 'Avtorji', view: 'authors', icon: 'groups' },
      { label: 'Zbori', view: 'choirs', icon: 'view_list' }
    ]
  },
  {
    label: 'Izpisi',
    children: [
      { label: 'Skladbe po avtorjih-zborih', view: 'reports', reportType: 'by-arranger', icon: 'receipt_long' },
      { label: 'Seznam pesmi', view: 'reports', reportType: 'songs', icon: 'list_alt' },
      { label: 'Seznam avtorjev', view: 'reports', reportType: 'authors', icon: 'person_search' },
      { label: 'Skladbe po pesnikih-zborih', view: 'reports', reportType: 'by-lyricist', icon: 'article' }
    ]
  },
  {
    label: 'Vzdrževanje',
    children: [
      { label: 'Shranjevanje podatkov', view: 'maintenance', action: 'backup', icon: 'save' },
      { label: 'Prenesi bazo', view: 'maintenance', action: 'download-db', icon: 'download' },
      { label: 'Sprememba datuma', view: 'maintenance', action: 'date', icon: 'event' },
      { label: 'Sprememba ure', view: 'maintenance', action: 'time', icon: 'schedule' },
      { label: 'Vračanje podatkov', view: 'maintenance', action: 'restore', icon: 'restore' }
    ]
  },
  {
    label: 'Servisni programi',
    children: [
      { label: 'Rebuild', view: 'maintenance', action: 'rebuild', icon: 'sync' },
      { label: 'Vnašalec', view: 'maintenance', action: 'operator', icon: 'person' }
    ]
  },
  { label: 'Moderni vmesnik', action: 'modern', children: [] },
  { label: 'Konec', children: [] }
];

const baseFlatViews = [
  { label: 'Pesmi', view: 'songs', icon: 'library_music' },
  { label: 'Opombe', view: 'notes', icon: 'inventory_2' },
  { label: 'Avtorji', view: 'authors', icon: 'groups' },
  { label: 'Zbori', view: 'choirs', icon: 'view_list' },
  { label: 'Izpisi', view: 'reports', icon: 'receipt_long' },
  { label: 'Vzdrževanje', view: 'maintenance', icon: 'settings' },
  { label: 'Baza', view: 'database', icon: 'storage' }
];

const reportOptions = [
  { label: 'Seznam pesmi', value: 'songs' },
  { label: 'Seznam avtorjev', value: 'authors' },
  { label: 'Seznam zborov', value: 'choirs' },
  { label: 'Skladbe po avtorjih-zborih', value: 'by-arranger' },
  { label: 'Skladbe po pesnikih-zborih', value: 'by-lyricist' }
];

const orderOptions = [
  { label: 'Abecedno', value: 'alpha' },
  { label: 'Po šifrah', value: 'number' }
];

const authorTypeOptions = [
  { label: 'Avtor glasbe', value: 1 },
  { label: 'Avtor besedila', value: 2 },
  { label: 'Drugo', value: 0 }
];

const songColumns = [
  { name: 'choirShort', label: 'Zbor', field: 'choirShort', align: 'left', sortable: true },
  { name: 'title', label: 'Naziv', field: 'title', align: 'left', sortable: true },
  { name: 'note', label: 'Opomba', field: 'note', align: 'left', sortable: true },
  { name: 'arrangerName', label: 'Avtor', field: 'arrangerName', align: 'left', sortable: true },
  { name: 'lyricistName', label: 'Pesnik', field: 'lyricistName', align: 'left', sortable: true },
  { name: 'verse', label: 'Verz', field: 'verse', align: 'left' }
];

const authorColumns = [
  { name: 'name', label: 'Naziv', field: 'name', align: 'left', sortable: true },
  { name: 'usageCount', label: 'Skladb', field: 'usageCount', align: 'right', sortable: true }
];

const choirColumns = [
  { name: 'name', label: 'Naziv', field: 'name', align: 'left' },
  { name: 'shortName', label: 'Kratko', field: 'shortName', align: 'left' }
];

const noteColumns = [
  { name: 'note', label: 'Opomba', field: 'note', align: 'left', sortable: true },
  { name: 'count', label: 'Skladb', field: 'count', align: 'right', sortable: true }
];

const currentChildren = computed(() => menuItems[selectedMain.value]?.children || []);
const databaseTableOptions = computed(() => databaseTables.value.map((table) => ({
  label: `${table.label} (${table.name})`,
  value: table.name
})));
const activeDatabaseTable = computed(() => databaseTables.value.find((table) => table.name === databaseTable.value) || null);
const databaseRowKey = computed(() => activeDatabaseTable.value?.rowKey || 'id');
const choirOptions = computed(() => [
  { label: 'VSI ZBORI', value: 0 },
  ...choirChoices.value.map((choir) => ({ label: `${choir.id} ${choir.name}`, value: choir.id }))
]);
const today = computed(() => {
  if (!appDate.value) return new Date().toLocaleDateString('sl-SI');
  const parsed = new Date(`${appDate.value}T00:00:00`);
  return Number.isNaN(parsed.getTime()) ? appDate.value : parsed.toLocaleDateString('sl-SI');
});
const currentOperator = computed(() => operatorName.value || 'dusan');
const isEditor = computed(() => entryMode.value === 'editor');
const isReadOnly = computed(() => !isEditor.value);
const entryModeLabel = computed(() => isEditor.value ? 'Urejevalni način' : 'Pregled kataloga');
const entryModeIcon = computed(() => isEditor.value ? 'edit_note' : 'visibility');
const flatViews = computed(() => (
  isReadOnly.value
    ? baseFlatViews.filter((item) => !['notes', 'maintenance', 'database'].includes(item.view))
    : baseFlatViews
));
const activeTitle = computed(() => baseFlatViews.find((item) => item.view === activeView.value)?.label || 'Melodija');
const statusLine = computed(() => 'ESC-konec  F1-potrditev  F4-nazaj  F5-šifre  F6-ABC  F7-izpis šifre  F8-izpis ABC  F10-brisanje');
const themeIcon = computed(() => theme.value === 'modern' ? 'terminal' : 'dashboard');
const showModernActions = computed(() => ['songs', 'authors', 'choirs', 'notes'].includes(activeView.value));
const showModernSearch = computed(() => ['songs', 'authors'].includes(activeView.value));
const dataLoading = computed(() => !loading.value && dataLoadingCount.value > 0);
const modernActionClass = computed(() => ({
  'is-songs': activeView.value === 'songs',
  'is-compact': activeView.value !== 'songs',
  'is-single': activeView.value === 'choirs'
}));
const hasSongFilters = computed(() => (
  Boolean(String(query.value || '').trim())
  || Boolean(choirFilter.value)
  || Boolean(songArrangerFilter.value)
  || Boolean(songLyricistFilter.value)
  || Boolean(noteFilter.value)
));
const showReportChoirFilter = computed(() => ['songs', 'by-arranger', 'by-lyricist'].includes(reportType.value));
const showReportAuthorFilter = computed(() => ['songs', 'authors', 'choirs', 'by-arranger', 'by-lyricist'].includes(reportType.value));
const searchLabel = computed(() => activeView.value === 'authors' ? 'Išči avtorja' : 'Išči skladbo, verz, avtorja, pesnika ali opombo');
const reportAuthorLabel = computed(() => {
  if (reportType.value === 'by-lyricist') return 'Pesnik';
  if (reportType.value === 'songs') return 'Išči';
  if (reportType.value === 'choirs') return 'Zbor';
  return 'Avtor';
});
const reportColumns = computed(() => {
  if (reportType.value === 'authors') {
    return [
      { name: 'name', label: 'Naziv', field: 'name', align: 'left', sortable: true },
      { name: 'usageCount', label: 'Skladb', field: 'usageCount', align: 'right', sortable: true }
    ];
  }
  if (reportType.value === 'choirs') {
    return [
      { name: 'name', label: 'Naziv', field: 'name', align: 'left', sortable: true },
      { name: 'shortName', label: 'Oznaka', field: 'shortName', align: 'left', sortable: true }
    ];
  }
  return [
    { name: 'choirShort', label: 'Zbor', field: 'choirShort', align: 'left', sortable: true },
    { name: 'title', label: 'Skladba', field: 'title', align: 'left', sortable: true },
    {
      name: 'activeAuthor',
      label: reportAuthorLabel.value,
      field: (row) => reportType.value === 'by-lyricist' ? row.lyricistName : row.arrangerName,
      align: 'left',
      sortable: true
    },
    { name: 'note', label: 'Opomba', field: 'note', align: 'left', sortable: true },
    { name: 'verse', label: 'Verz', field: 'verse', align: 'left', sortable: true }
  ];
});
const reportRowKey = computed(() => {
  if (reportType.value === 'authors' || reportType.value === 'choirs') return 'id';
  return 'ownkey';
});
const reportPrintTitle = computed(() => reportOptions.find((option) => option.value === reportType.value)?.label || 'Izpis');
const reportPrintMeta = computed(() => {
  const parts = [
    'COMFIN VINKO STEGEL',
    `MELODIJA 5.0  ${new Date().toLocaleString('sl-SI')}`,
    orderOptions.find((option) => option.value === reportOrder.value)?.label || ''
  ];
  if (showReportChoirFilter.value) {
    parts.push(choirOptions.value.find((option) => option.value === choirFilter.value)?.label || 'VSI ZBORI');
  }
  if (showReportAuthorFilter.value && reportAuthor.value) {
    parts.push(authorOptions.value.find((option) => option.value === reportAuthor.value)?.label || `${reportAuthorLabel.value} ${reportAuthor.value}`);
  }
  if (reportFilter.value) {
    parts.push(`Filter: ${reportFilter.value}`);
  }
  return parts.filter(Boolean).join(' | ');
});
const filteredReportRows = computed(() => {
  const needle = String(reportFilter.value || '').trim().toLocaleLowerCase('sl-SI');
  if (!needle) return reportRows.value;
  return reportRows.value.filter((row) => (
    reportColumns.value.some((column) => String(reportCell(row, column)).toLocaleLowerCase('sl-SI').includes(needle))
  ));
});
const maintenanceText = computed(() => [
  `SQLite: ${dbPath.value}`,
  `Varnostne kopije: ${maintenanceBackups.value.length}`,
  '',
  ...maintenanceBackups.value.map((backup) => `${backup.modified || ''}  ${backup.name || backup.file}`)
].join('\n'));
const visibleDosSongs = computed(() => songs.value.slice(dosOffset.value, dosOffset.value + 12));
const visibleDosAuthors = computed(() => authors.value.slice(dosOffset.value, dosOffset.value + 13));
const visibleDosChoirs = computed(() => choirs.value.slice(dosOffset.value, dosOffset.value + 13));
const visibleLookupRows = computed(() => lookupRows.value.slice(lookupOffset.value, lookupOffset.value + 12));

function emptySong() {
  return {
    ownkey: 0,
    choirId: 3,
    number: null,
    title: '',
    verse: '',
    arrangerId: 0,
    lyricistId: 0,
    note: ''
  };
}

function assign(target, source) {
  Object.keys(target).forEach((key) => {
    target[key] = source[key] ?? (typeof target[key] === 'number' ? 0 : '');
  });
}

function notifyError(error) {
  $q.notify({ type: 'negative', message: error?.message || String(error) });
}

async function withDataLoading(task, message = DATA_LOADING_MESSAGE) {
  dataLoadingMessage.value = message;
  dataLoadingCount.value += 1;
  try {
    return await task();
  } finally {
    dataLoadingCount.value = Math.max(0, dataLoadingCount.value - 1);
    if (!dataLoadingCount.value) {
      dataLoadingMessage.value = DATA_LOADING_MESSAGE;
    }
  }
}

function reportCell(row, column) {
  const value = typeof column.field === 'function' ? column.field(row) : row[column.field];
  return value ?? '';
}

function printReportRowKey(row) {
  return row?.[reportRowKey.value] ?? `${reportType.value}-${filteredReportRows.value.indexOf(row)}`;
}

async function sha512Hex(value) {
  const data = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest('SHA-512', data);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

async function editorTokenForPassword(password) {
  const passwordHash = await sha512Hex(password);
  return sha512Hex(`${EDITOR_PASSWORD_SALT}:${passwordHash}`);
}

function restoreEntryMode() {
  const savedMode = localStorage.getItem(ENTRY_MODE_KEY);
  const savedToken = localStorage.getItem(EDITOR_TOKEN_KEY);
  if (savedMode === 'editor' && savedToken === EDITOR_PASSWORD_TOKEN) {
    entryMode.value = 'editor';
    return;
  }
  if (savedMode === 'catalog') {
    entryMode.value = 'catalog';
  }
}

function persistEntryMode(mode) {
  entryMode.value = mode;
  localStorage.setItem(ENTRY_MODE_KEY, mode);
}

async function enterCatalogMode() {
  persistEntryMode('catalog');
  await enterIntro();
}

async function requestEditorMode({ enterAfterUnlock = true } = {}) {
  entryPasswordEnterAfterUnlock.value = enterAfterUnlock;
  if (localStorage.getItem(EDITOR_TOKEN_KEY) === EDITOR_PASSWORD_TOKEN) {
    persistEntryMode('editor');
    if (entryPasswordEnterAfterUnlock.value) await enterIntro();
    return;
  }
  entryPassword.value = '';
  entryPasswordError.value = '';
  entryPasswordVisible.value = true;
  nextTick(() => entryPasswordInput.value?.focus());
}

async function submitEditorPassword() {
  const token = await editorTokenForPassword(entryPassword.value);
  if (token === EDITOR_PASSWORD_TOKEN) {
    localStorage.setItem(EDITOR_TOKEN_KEY, token);
    persistEntryMode('editor');
    entryPassword.value = '';
    entryPasswordError.value = '';
    entryPasswordVisible.value = false;
    if (entryPasswordEnterAfterUnlock.value) await enterIntro();
    return;
  }
  entryPassword.value = '';
  entryPasswordError.value = 'Napačno geslo.';
  nextTick(() => entryPasswordInput.value?.focus());
}

function cancelEditorPassword() {
  entryPassword.value = '';
  entryPasswordError.value = '';
  entryPasswordVisible.value = false;
  entryPasswordEnterAfterUnlock.value = true;
}

async function toggleEntryMode() {
  if (isEditor.value) {
    persistEntryMode('catalog');
    return;
  }
  await requestEditorMode({ enterAfterUnlock: introVisible.value });
}

function requireEditor() {
  if (isEditor.value) return true;
  $q.notify({ type: 'warning', message: 'Pregled kataloga je samo za branje.' });
  return false;
}

function logout() {
  localStorage.removeItem(ENTRY_MODE_KEY);
  localStorage.removeItem(EDITOR_TOKEN_KEY);
  entryMode.value = '';
  returnToIntro();
}

async function initialize() {
  theme.value = localStorage.getItem('melodija.theme') || 'dos';
  restoreEntryMode();
  loading.value = false;
}

async function ensureBootstrap() {
  if (bootstrapPromise) return bootstrapPromise;
  bootstrapPromise = (async () => {
    const boot = await api.bootstrap();
    dbPath.value = boot.dbPath;
    Object.assign(counts, boot.counts);
    appDate.value = boot.settings['app.date'] || '';
    appTime.value = boot.settings['app.time'] || '';
    operatorName.value = boot.settings['operator.name'] || boot.operator?.name || 'dusan';
    choirChoices.value = boot.choirs || [];
    return boot;
  })().catch((error) => {
    bootstrapPromise = null;
    throw error;
  });
  return bootstrapPromise;
}

async function refreshSongs() {
  const result = await withDataLoading(() => api.songs({
    query: query.value,
    choir: choirFilter.value || '',
    arranger: songArrangerFilter.value || '',
    lyricist: songLyricistFilter.value || '',
    note: noteFilter.value || '',
    sort: songSort.value,
    limit: 10000
  }));
  songs.value = result.rows;
  clampDosSelection();
  if (!result.rows.length) {
    selectedRows.value = [];
    clearSongContext();
    if (activeView.value === 'songs') assign(songForm, emptySong());
    return;
  }
  if (theme.value === 'dos' && activeView.value === 'songs' && !songForm.ownkey && result.rows[0]) {
    editSong(result.rows[0]);
  }
}

async function refreshAuthors() {
  const result = await withDataLoading(() => api.authors({ query: activeView.value === 'authors' ? query.value : '', sort: authorSort.value, limit: 10000 }));
  authors.value = result.rows;
  clampDosSelection();
}

async function refreshChoirs() {
  const result = await withDataLoading(() => api.choirs({ sort: choirSort.value }));
  choirs.value = result.rows;
  choirChoices.value = result.rows;
  clampDosSelection();
}

async function refreshNotes() {
  const result = await withDataLoading(() => api.notes({ query: noteSearch.value || '', limit: 300 }));
  notes.value = result.rows;
  if (!selectedNoteRows.value[0] && result.rows[0]) {
    editNote(result.rows[0]);
  }
}

async function refreshActive() {
  if (activeView.value === 'songs') await refreshSongs();
  if (activeView.value === 'authors') await refreshAuthors();
  if (activeView.value === 'choirs') await refreshChoirs();
  if (activeView.value === 'notes') await refreshNotes();
  if (activeView.value === 'reports') await generateReport();
}

function resetDosPosition() {
  selectedResult.value = 0;
  dosOffset.value = 0;
}

async function refreshActiveFromStart() {
  resetDosPosition();
  await refreshActive();
  if (theme.value === 'dos') selectDosResult(0);
}

async function refreshSongsFromStart() {
  resetDosPosition();
  await refreshSongs();
  if (theme.value === 'dos') selectDosResult(0);
}

async function refreshSongsFromRoleFilter() {
  await refreshSongsFromStart();
}

async function clearSongFilters() {
  query.value = '';
  choirFilter.value = 0;
  songArrangerFilter.value = null;
  songLyricistFilter.value = null;
  noteFilter.value = null;
  await refreshSongsFromStart();
}

async function normalizeChoirFilter(value) {
  choirFilter.value = value || 0;
  await refreshActiveFromStart();
}

async function normalizeReportChoirFilter(value) {
  choirFilter.value = value || 0;
  await generateReport();
}

async function refreshAuthorsFromStart() {
  resetDosPosition();
  await refreshAuthors();
  if (theme.value === 'dos') selectDosResult(0);
}

async function showClassicSongs() {
  await refreshSongsFromStart();
}

async function showClassicAuthors() {
  await refreshAuthorsFromStart();
}

async function showClassicChoirs() {
  resetDosPosition();
  await refreshChoirs();
  selectDosResult(0);
}

function editSong(song) {
  assign(songForm, {
    ownkey: song.ownkey,
    choirId: song.choirId,
    number: song.number,
    title: song.title,
    verse: song.verse,
    arrangerId: song.arrangerId,
    lyricistId: song.lyricistId,
    note: song.note
  });
  selectedRows.value = [song];
  loadSongContext(song);
}

function closeSongEditor() {
  selectedRows.value = [];
  assign(songForm, emptySong());
  clearSongContext();
}

async function fillNextSongNumber() {
  const result = await api.nextSongNumber(songForm.choirId || 3);
  songForm.number = result.nextNumber;
}

async function newSong() {
  if (!requireEditor()) return;
  assign(songForm, emptySong());
  songForm.choirId = choirFilter.value || 3;
  selectedRows.value = [{ ...songForm }];
  clearSongContext();
  await fillNextSongNumber();
  selectedRows.value = [{ ...songForm }];
}

async function fillNextAuthorId() {
  const result = await api.nextAuthorId();
  authorForm.id = result.nextId;
}

async function newAuthor() {
  if (!requireEditor()) return;
  assign(authorForm, { id: null, name: '', type: 1 });
  selectedAuthorRows.value = [{ ...authorForm }];
  await fillNextAuthorId();
  selectedAuthorRows.value = [{ ...authorForm }];
}

async function fillNextChoirId() {
  const result = await api.nextChoirId();
  choirForm.id = result.nextId;
}

async function newChoir() {
  if (!requireEditor()) return;
  assign(choirForm, { id: null, name: '', shortName: '' });
  selectedChoirRows.value = [{ ...choirForm }];
  await fillNextChoirId();
  selectedChoirRows.value = [{ ...choirForm }];
}

function newRecord() {
  if (!requireEditor()) return;
  if (activeView.value === 'songs') newSong();
  if (activeView.value === 'authors') newAuthor();
  if (activeView.value === 'choirs') newChoir();
}

async function saveSong() {
  if (!requireEditor()) return;
  try {
    const saved = await api.saveSong({ ...songForm });
    editSong(saved);
    await refreshSongs();
    $q.notify({ type: 'positive', message: 'Skladba shranjena.' });
  } catch (error) {
    notifyError(error);
  }
}

async function removeSong() {
  if (!requireEditor()) return;
  if (!songForm.ownkey) return;
  if (!window.confirm('Izbrišem skladbo?')) return;
  try {
    await api.deleteSong(songForm.ownkey);
    await refreshSongs();
    await newSong();
    $q.notify({ type: 'positive', message: 'Skladba izbrisana.' });
  } catch (error) {
    notifyError(error);
  }
}

function editAuthor(author) {
  assign(authorForm, author);
  selectedAuthorRows.value = [author];
  loadAuthorContext(author.id);
}

function closeAuthorEditor() {
  selectedAuthorRows.value = [];
  assign(authorForm, { id: null, name: '', type: 1 });
  clearAuthorContext();
}

function toggleAuthorEditor(author) {
  if (selectedAuthorRows.value[0]?.id === author?.id) {
    closeAuthorEditor();
    return;
  }
  editAuthor(author);
}

async function saveAuthor() {
  if (!requireEditor()) return;
  try {
    const saved = await api.saveAuthor({ ...authorForm });
    editAuthor(saved);
    await refreshAuthors();
    await filterAuthors('', (fn) => fn());
    $q.notify({ type: 'positive', message: 'Avtor shranjen.' });
  } catch (error) {
    notifyError(error);
  }
}

async function removeAuthor() {
  if (!requireEditor()) return;
  if (!authorForm.id) return;
  if (!window.confirm('Izbrišem avtorja?')) return;
  try {
    await api.deleteAuthor(authorForm.id);
    await refreshAuthors();
    await newAuthor();
    await filterAuthors('', (fn) => fn());
    $q.notify({ type: 'positive', message: 'Avtor izbrisan.' });
  } catch (error) {
    notifyError(error);
  }
}

function editChoir(choir) {
  assign(choirForm, choir);
  selectedChoirRows.value = [choir];
  loadChoirContext(choir.id);
}

function closeChoirEditor() {
  selectedChoirRows.value = [];
  assign(choirForm, { id: null, name: '', shortName: '' });
  clearChoirContext();
}

function editNote(note) {
  if (!note) return;
  selectedNoteRows.value = [note];
}

function activeDosRows() {
  if (activeView.value === 'songs') return songs.value;
  if (activeView.value === 'authors') return authors.value;
  if (activeView.value === 'choirs') return choirs.value;
  return [];
}

function dosPageSize() {
  if (activeView.value === 'songs') return 12;
  if (activeView.value === 'authors' || activeView.value === 'choirs') return 13;
  return 12;
}

function editActiveDosRow(row) {
  if (!row) return;
  if (activeView.value === 'songs') editSong(row);
  if (activeView.value === 'authors') editAuthor(row);
  if (activeView.value === 'choirs') editChoir(row);
}

function clampDosSelection() {
  const rows = activeDosRows();
  if (!rows.length) {
    selectedResult.value = 0;
    dosOffset.value = 0;
    return;
  }
  selectedResult.value = Math.max(0, Math.min(selectedResult.value, rows.length - 1));
  const pageSize = dosPageSize();
  if (selectedResult.value < dosOffset.value) {
    dosOffset.value = selectedResult.value;
  }
  if (selectedResult.value >= dosOffset.value + pageSize) {
    dosOffset.value = selectedResult.value - pageSize + 1;
  }
  dosOffset.value = Math.max(0, Math.min(dosOffset.value, Math.max(0, rows.length - pageSize)));
}

function selectDosResult(index) {
  const rows = activeDosRows();
  if (!rows.length) {
    selectedResult.value = 0;
    dosOffset.value = 0;
    return;
  }
  selectedResult.value = Math.max(0, Math.min(index, rows.length - 1));
  clampDosSelection();
  editActiveDosRow(rows[selectedResult.value]);
}

async function saveChoir() {
  if (!requireEditor()) return;
  try {
    const saved = await api.saveChoir({ ...choirForm });
    editChoir(saved);
    await refreshChoirs();
    $q.notify({ type: 'positive', message: 'Zbor shranjen.' });
  } catch (error) {
    notifyError(error);
  }
}

async function removeChoir() {
  if (!requireEditor()) return;
  if (!choirForm.id) return;
  if (!window.confirm('Izbrišem zbor?')) return;
  try {
    await api.deleteChoir(choirForm.id);
    await refreshChoirs();
    await newChoir();
    $q.notify({ type: 'positive', message: 'Zbor izbrisan.' });
  } catch (error) {
    notifyError(error);
  }
}

async function filterAuthors(value, update) {
  const result = await api.authors({ query: value || '', limit: 10000 });
  const mapped = result.rows.map((author) => ({ label: `${author.id} ${author.name}`, value: author.id }));
  if (typeof update === 'function') {
    update(() => {
      authorOptions.value = mapped;
    });
  } else {
    authorOptions.value = mapped;
  }
}

async function filterNotes(value, update) {
  const result = await api.notes({ query: value || '', limit: 300 });
  const mapped = result.rows.map((row) => ({
    label: `${row.note} (${row.count})`,
    value: row.note
  }));
  if (typeof update === 'function') {
    update(() => {
      noteOptions.value = mapped;
    });
  } else {
    noteOptions.value = mapped;
  }
}

function songCode(row) {
  return `${row.choirShort || row.choirId} ${String(row.number).padStart(5, '0')}`;
}

function relationRows(result, ownkey) {
  return (result?.rows || []).filter((row) => row.ownkey !== ownkey).slice(0, 6);
}

function clearSongContext() {
  Object.assign(songContext, {
    sameChoir: [],
    sameChoirTotal: 0,
    arranger: [],
    arrangerTotal: 0,
    lyricist: [],
    lyricistTotal: 0,
    note: [],
    noteTotal: 0
  });
}

function clearAuthorContext() {
  Object.assign(authorContext, { arranged: [], arrangedTotal: 0, lyricist: [], lyricistTotal: 0 });
}

function clearChoirContext() {
  Object.assign(choirContext, { songs: [], total: 0 });
}

async function loadSongContext(song) {
  const requestId = ++songContextRequest;
  clearSongContext();
  if (!song?.ownkey) return;
  const [sameChoir, arranger, lyricist, note] = await Promise.all([
    song.choirId ? api.songs({ choir: song.choirId, sort: 'title', limit: 9 }) : Promise.resolve({ rows: [], total: 0 }),
    song.arrangerId ? api.songs({ arranger: song.arrangerId, sort: 'title', limit: 9 }) : Promise.resolve({ rows: [], total: 0 }),
    song.lyricistId ? api.songs({ lyricist: song.lyricistId, sort: 'title', limit: 9 }) : Promise.resolve({ rows: [], total: 0 }),
    song.note ? api.songs({ note: song.note, sort: 'title', limit: 9 }) : Promise.resolve({ rows: [], total: 0 })
  ]);
  if (requestId !== songContextRequest) return;
  Object.assign(songContext, {
    sameChoir: relationRows(sameChoir, song.ownkey),
    sameChoirTotal: sameChoir.total || 0,
    arranger: relationRows(arranger, song.ownkey),
    arrangerTotal: arranger.total || 0,
    lyricist: relationRows(lyricist, song.ownkey),
    lyricistTotal: lyricist.total || 0,
    note: relationRows(note, song.ownkey),
    noteTotal: note.total || 0
  });
}

async function loadAuthorContext(authorId) {
  const requestId = ++authorContextRequest;
  clearAuthorContext();
  if (!authorId) return;
  const [arranged, lyricist] = await Promise.all([
    api.songs({ arranger: authorId, sort: 'title', limit: 7 }),
    api.songs({ lyricist: authorId, sort: 'title', limit: 7 })
  ]);
  if (requestId !== authorContextRequest) return;
  Object.assign(authorContext, {
    arranged: (arranged.rows || []).slice(0, 6),
    arrangedTotal: arranged.total || 0,
    lyricist: (lyricist.rows || []).slice(0, 6),
    lyricistTotal: lyricist.total || 0
  });
}

async function loadChoirContext(choirId) {
  const requestId = ++choirContextRequest;
  clearChoirContext();
  if (!choirId) return;
  const result = await api.songs({ choir: choirId, sort: 'title', limit: 7 });
  if (requestId !== choirContextRequest) return;
  Object.assign(choirContext, {
    songs: (result.rows || []).slice(0, 6),
    total: result.total || 0
  });
}

async function filterSongsByChoir(choirId) {
  await openView('songs');
  query.value = '';
  songArrangerFilter.value = null;
  songLyricistFilter.value = null;
  noteFilter.value = null;
  choirFilter.value = choirId || 0;
  await refreshSongsFromStart();
}

async function filterSongsByArranger(authorId) {
  await openView('songs');
  query.value = '';
  choirFilter.value = 0;
  noteFilter.value = null;
  songLyricistFilter.value = null;
  songArrangerFilter.value = authorId || null;
  await refreshSongsFromStart();
}

async function filterSongsByLyricist(authorId) {
  await openView('songs');
  query.value = '';
  choirFilter.value = 0;
  noteFilter.value = null;
  songArrangerFilter.value = null;
  songLyricistFilter.value = authorId || null;
  await refreshSongsFromStart();
}

async function filterSongsByNote(note) {
  await openView('songs');
  query.value = '';
  choirFilter.value = 0;
  songArrangerFilter.value = null;
  songLyricistFilter.value = null;
  noteFilter.value = note || null;
  await refreshSongsFromStart();
}

async function openAuthorById(authorId) {
  if (!authorId) return;
  await openView('authors');
  query.value = '';
  await refreshAuthors();
  const author = authors.value.find((row) => row.id === authorId);
  if (author) editAuthor(author);
}

async function openChoirById(choirId) {
  if (!choirId) return;
  await openView('choirs');
  const choir = choirs.value.find((row) => row.id === choirId);
  if (choir) editChoir(choir);
}

async function focusSong(row) {
  if (!row?.ownkey) return;
  activeView.value = 'songs';
  query.value = '';
  songArrangerFilter.value = null;
  songLyricistFilter.value = null;
  noteFilter.value = null;
  choirFilter.value = row.choirId || 0;
  await refreshSongs();
  const visible = songs.value.find((song) => song.ownkey === row.ownkey) || row;
  editSong(visible);
}

async function filterQuickJump(value, update) {
  const queryText = String(value || '').trim();
  if (!queryText) {
    update(() => {
      quickJumpOptions.value = [];
    });
    return;
  }
  const result = await api.quickSearch({ query: queryText, limit: 30 });
  const typeLabels = { song: 'Skladba', author: 'Avtor', choir: 'Zbor', note: 'Opomba' };
  update(() => {
    quickJumpOptions.value = result.rows.map((row) => ({
      ...row,
      typeLabel: typeLabels[row.type] || row.type
    }));
  });
}

async function openQuickJump(option) {
  if (!option?.item) return;
  if (option.type === 'song') {
    await openView('songs');
    editSong(option.item);
  } else if (option.type === 'author') {
    await openView('authors');
    editAuthor(option.item);
  } else if (option.type === 'choir') {
    await openView('choirs');
    editChoir(option.item);
  } else if (option.type === 'note') {
    await filterSongsByNote(option.item.note);
  }
  quickJump.value = null;
}

async function generateReport() {
  const result = await withDataLoading(() => api.report({
    type: reportType.value,
    choir: choirFilter.value || '',
    author: reportAuthor.value || '',
    order: reportOrder.value
  }));
  reportText.value = result.lines.join('\n');
  reportRows.value = result.rows || [];
}

async function reportOptionsChanged() {
  syncClassicReportMenuSelection();
  if (!showReportAuthorFilter.value) {
    reportAuthor.value = null;
  }
  reportText.value = '';
  reportRows.value = [];
}

function syncClassicReportMenuSelection() {
  const reportMainIndex = menuItems.findIndex((item) => item.label === 'Izpisi');
  if (reportMainIndex < 0) return;
  const childIndex = menuItems[reportMainIndex].children.findIndex((item) => item.reportType === reportType.value);
  if (childIndex < 0) return;
  selectedMain.value = reportMainIndex;
  selectedChild.value = childIndex;
  menuLevel.value = 'child';
}

async function printReport() {
  await generateReport();
  if (!reportText.value && !reportRows.value.length) return;
  await nextTick();
  window.print();
}

async function openReportRow(row) {
  if (!row) return;
  if (row.ownkey) {
    await focusSong(row);
    return;
  }
  if (reportType.value === 'authors') {
    await openAuthorById(row.id);
    return;
  }
  if (reportType.value === 'choirs') {
    await openChoirById(row.id);
  }
}

async function listDosByCode() {
  await openDosLookup('number');
}

async function listDosByAlpha() {
  await openDosLookup('alpha');
}

function mapSongLookup(row) {
  return {
    key: `song-${row.ownkey}`,
    code: `${row.choirShort || row.choirId} ${String(row.number).padStart(5, '0')}`,
    name: row.title,
    extra: row.arrangerName || row.verse || '',
    row
  };
}

function mapAuthorLookup(row) {
  return {
    key: `author-${row.id}`,
    code: String(row.id).padStart(6, '0'),
    name: row.name,
    extra: row.type ? String(row.type) : '',
    row
  };
}

function mapChoirLookup(row) {
  return {
    key: `choir-${row.id}`,
    code: String(row.id).padStart(2, '0'),
    name: row.name,
    extra: row.shortName || '',
    row
  };
}

function targetFromActiveField() {
  return document.activeElement?.dataset?.dosField || '';
}

async function openDosLookup(order) {
  if (!['songs', 'authors', 'choirs', 'reports'].includes(activeView.value)) return;
  const target = targetFromActiveField()
    || (activeView.value === 'songs' ? 'song.record'
      : activeView.value === 'authors' ? 'author.record'
        : activeView.value === 'choirs' ? 'choir.record'
          : reportType.value === 'authors' ? 'report.author'
            : 'report.choir');
  lookupTarget.value = target;
  lookupSelected.value = 0;
  lookupOffset.value = 0;

  if (target.includes('choir')) {
    const result = await withDataLoading(() => api.choirs({ sort: order === 'number' ? 'id' : 'name' }));
    lookupTitle.value = order === 'number' ? 'Zbori po šifrah' : 'Zbori ABC';
    lookupRows.value = result.rows.map(mapChoirLookup);
  } else if (target.includes('author') || target.includes('lyricist') || target.includes('arranger')) {
    const result = await withDataLoading(() => api.authors({ query: '', sort: order === 'number' ? 'id' : 'name', limit: 10000 }));
    lookupTitle.value = order === 'number' ? 'Avtorji po šifrah' : 'Avtorji ABC';
    lookupRows.value = result.rows.map(mapAuthorLookup);
  } else {
    const result = await withDataLoading(() => api.songs({
      query: query.value,
      choir: choirFilter.value || '',
      sort: order === 'number' ? 'number' : 'title',
      limit: 10000
    }));
    lookupTitle.value = order === 'number' ? 'Pesmi po šifrah' : 'Pesmi ABC';
    lookupRows.value = result.rows.map(mapSongLookup);
  }

  lookupVisible.value = lookupRows.value.length > 0;
}

async function openSongRelationLookup(role, authorId, order) {
  if (!authorId) {
    await openDosLookup(order);
    return;
  }
  lookupTarget.value = 'song.record';
  lookupSelected.value = 0;
  lookupOffset.value = 0;
  const result = await withDataLoading(() => api.songs({
    [role]: authorId,
    sort: order === 'number' ? 'number' : 'title',
    limit: 10000
  }));
  lookupTitle.value = role === 'lyricist'
    ? (order === 'number' ? 'Pesmi pesnika po šifrah' : 'Pesmi pesnika ABC')
    : (order === 'number' ? 'Pesmi avtorja po šifrah' : 'Pesmi avtorja ABC');
  lookupRows.value = result.rows.map(mapSongLookup);
  lookupVisible.value = lookupRows.value.length > 0;
}

async function contextualDosListOrReport(order) {
  const target = targetFromActiveField();
  if (target === 'song.arranger') {
    await openSongRelationLookup('arranger', songForm.arrangerId, order);
    return;
  }
  if (target === 'song.lyricist') {
    await openSongRelationLookup('lyricist', songForm.lyricistId, order);
    return;
  }
  if (target.startsWith('song.') || target.startsWith('report.')) {
    await openDosLookup(order);
    return;
  }
  await reportActiveDos(order);
}

function selectLookupRow(index) {
  if (!lookupRows.value.length) return;
  lookupSelected.value = Math.max(0, Math.min(index, lookupRows.value.length - 1));
  if (lookupSelected.value < lookupOffset.value) {
    lookupOffset.value = lookupSelected.value;
  }
  if (lookupSelected.value >= lookupOffset.value + 12) {
    lookupOffset.value = lookupSelected.value - 11;
  }
  lookupOffset.value = Math.max(0, Math.min(lookupOffset.value, Math.max(0, lookupRows.value.length - 12)));
}

function applyLookupRow() {
  const selected = lookupRows.value[lookupSelected.value]?.row;
  if (!selected) return;
  const target = lookupTarget.value;

  if (target.includes('choir')) {
    if (target.startsWith('song.')) {
      songForm.choirId = selected.id;
    } else if (target.startsWith('choir.')) {
      editChoir(selected);
    } else {
      choirFilter.value = selected.id;
      if (activeView.value === 'reports') generateReport();
      if (activeView.value === 'songs') refreshSongsFromStart();
    }
  } else if (target.includes('lyricist')) {
    songForm.lyricistId = selected.id;
  } else if (target.includes('arranger')) {
    songForm.arrangerId = selected.id;
  } else if (target.startsWith('author.')) {
    editAuthor(selected);
  } else if (target === 'report.author') {
    reportAuthor.value = selected.id;
    generateReport();
  } else {
    editSong(selected);
  }

  lookupVisible.value = false;
  lookupRows.value = [];
}

function closeLookup() {
  lookupVisible.value = false;
  lookupRows.value = [];
}

async function sortDosListByCode() {
  if (activeView.value === 'songs') {
    songSort.value = 'number';
    await refreshSongsFromStart();
  } else if (activeView.value === 'authors') {
    authorSort.value = 'id';
    await refreshAuthorsFromStart();
  } else if (activeView.value === 'choirs') {
    choirSort.value = 'id';
    resetDosPosition();
    await refreshChoirs();
    selectDosResult(0);
  }
}

async function sortDosListByAlpha() {
  if (activeView.value === 'songs') {
    songSort.value = 'title';
    await refreshSongsFromStart();
  } else if (activeView.value === 'authors') {
    authorSort.value = 'name';
    await refreshAuthorsFromStart();
  } else if (activeView.value === 'choirs') {
    choirSort.value = 'name';
    resetDosPosition();
    await refreshChoirs();
    selectDosResult(0);
  }
}

async function reportActiveDos(order) {
  if (activeView.value === 'songs') {
    reportType.value = 'songs';
  } else if (activeView.value === 'authors') {
    reportType.value = 'authors';
  } else if (activeView.value === 'choirs') {
    reportType.value = 'choirs';
  } else if (activeView.value !== 'reports') {
    return;
  }
  reportOrder.value = order;
  await openView('reports');
  await generateReport();
}

async function confirmActiveDos() {
  if (activeView.value === 'menu') {
    menuLevel.value === 'child' ? await activateChild() : activateMain();
  } else if (targetFromActiveField() === 'song.number') {
    await fillNextSongNumber();
    moveDosField(1);
  } else if (targetFromActiveField() === 'author.id') {
    await newAuthor();
    moveDosField(1);
  } else if (targetFromActiveField() === 'choir.id') {
    await newChoir();
    moveDosField(1);
  } else if (activeView.value === 'songs') {
    await saveSong();
  } else if (activeView.value === 'authors') {
    await saveAuthor();
  } else if (activeView.value === 'choirs') {
    await saveChoir();
  } else if (activeView.value === 'reports') {
    await generateReport();
  }
}

async function deleteActiveDos() {
  if (activeView.value === 'songs') await removeSong();
  if (activeView.value === 'authors') await removeAuthor();
  if (activeView.value === 'choirs') await removeChoir();
}

function goBackDos() {
  if (introVisible.value) return;
  if (activeView.value !== 'menu') {
    activeView.value = 'menu';
    menuLevel.value = 'child';
    return;
  }
  if (menuLevel.value === 'child') {
    menuLevel.value = 'main';
  }
}

function navigateModernRows(rows, selected, edit, delta) {
  if (!rows.length) return false;
  const currentKey = selected.value[0]?.ownkey ?? selected.value[0]?.id;
  const current = rows.findIndex((row) => (row.ownkey ?? row.id) === currentKey);
  const index = current < 0 ? 0 : Math.max(0, Math.min(current + delta, rows.length - 1));
  edit(rows[index]);
  return true;
}

function dosFieldElements() {
  return Array.from(document.querySelectorAll('.dos-panel input, .dos-panel select, .dos-panel button'))
    .filter((element) => !element.disabled && element.offsetParent !== null);
}

function activeDosFieldIndex() {
  const fields = dosFieldElements();
  return { fields, index: fields.indexOf(document.activeElement) };
}

function focusDosField(index) {
  const fields = dosFieldElements();
  if (!fields.length) return false;
  const clamped = Math.max(0, Math.min(index, fields.length - 1));
  fields[clamped]?.focus();
  fields[clamped]?.select?.();
  return true;
}

function moveDosField(delta) {
  const { fields, index } = activeDosFieldIndex();
  if (!fields.length) return false;
  const current = index < 0 ? 0 : index;
  const target = Math.max(0, Math.min(current + delta, fields.length - 1));
  fields[target]?.focus();
  fields[target]?.select?.();
  return true;
}

function resetDosFieldOrExit() {
  const { fields, index } = activeDosFieldIndex();
  if (!fields.length || index <= 0) {
    goBackDos();
    return;
  }
  fields[0]?.focus();
  fields[0]?.select?.();
}

async function loadDatabaseTables() {
  if (databaseTables.value.length) return;
  const result = await api.databaseTables();
  databaseTables.value = result.tables || [];
  if (!databaseTables.value.some((table) => table.name === databaseTable.value)) {
    databaseTable.value = databaseTables.value[0]?.name || 'songs';
  }
  const active = databaseTables.value.find((table) => table.name === databaseTable.value);
  if (active?.defaultSort) {
    databasePagination.value.sortBy = active.defaultSort;
  }
}

async function refreshDatabase() {
  await loadDatabaseTables();
  const pagination = databasePagination.value;
  databaseLoading.value = true;
  try {
    const result = await api.databaseRows(databaseTable.value, {
      query: databaseFilter.value || '',
      sortBy: pagination.sortBy || activeDatabaseTable.value?.defaultSort || '',
      descending: pagination.descending ? 'true' : '',
      limit: pagination.rowsPerPage,
      offset: (pagination.page - 1) * pagination.rowsPerPage
    });
    databaseRows.value = result.rows || [];
    databaseAllColumns.value = result.table?.columns || [];
    refreshDatabaseColumns();
    databasePagination.value = {
      ...databasePagination.value,
      sortBy: result.sortBy || databasePagination.value.sortBy,
      descending: Boolean(result.descending),
      rowsNumber: result.total || 0
    };
  } finally {
    databaseLoading.value = false;
  }
}

function refreshDatabaseColumns() {
  databaseColumns.value = databaseAllColumns.value
    .filter((column) => databaseShowTechnical.value || !column.technical)
    .map((column) => ({
      name: column.name,
      label: column.label,
      field: column.name,
      align: column.align || 'left',
      sortable: true
    }));
}

async function refreshDatabaseFromStart() {
  databasePagination.value.page = 1;
  await refreshDatabase();
}

async function requestDatabaseRows(props = {}) {
  if (props.pagination) {
    databasePagination.value = {
      ...databasePagination.value,
      ...props.pagination
    };
  }
  await refreshDatabase();
}

async function selectDatabaseTable() {
  const table = databaseTables.value.find((item) => item.name === databaseTable.value);
  databasePagination.value = {
    sortBy: table?.defaultSort || 'id',
    descending: false,
    page: 1,
    rowsPerPage: databasePagination.value.rowsPerPage,
    rowsNumber: 0
  };
  databaseRows.value = [];
  databaseAllColumns.value = [];
  databaseColumns.value = [];
  await refreshDatabase();
}

async function loadMaintenance() {
  const result = await api.maintenance();
  dbPath.value = result.dbPath || dbPath.value;
  maintenanceBackups.value = result.backups || [];
  appDate.value = result.settings?.['app.date'] || appDate.value;
  appTime.value = result.settings?.['app.time'] || appTime.value;
  operatorName.value = result.settings?.['operator.name'] || result.operator?.name || operatorName.value || 'dusan';
}

async function runMaintenanceAction(action) {
  activeView.value = 'maintenance';
  maintenanceMessage.value = '';
  if (!requireEditor()) {
    maintenanceMessage.value = 'Pregled kataloga je samo za branje.';
    await loadMaintenance();
    return;
  }
  if (action === 'date') {
    maintenanceMessage.value = 'Vnesi datum aplikacije in potrdi Datum/Ura.';
    await loadMaintenance();
    return;
  }
  if (action === 'time') {
    maintenanceMessage.value = 'Vnesi uro aplikacije in potrdi Datum/Ura.';
    await loadMaintenance();
    return;
  }
  if (action === 'operator') {
    maintenanceMessage.value = 'Vnesi vnašalca in potrdi Vnašalec.';
    await loadMaintenance();
    return;
  }
  if (action === 'restore' && !window.confirm('Vrnem zadnjo varnostno kopijo baze melodija.db?')) {
    maintenanceMessage.value = 'Vračanje podatkov preklicano.';
    await loadMaintenance();
    return;
  }
  const result = action === 'backup'
    ? await api.backupDatabase()
    : action === 'restore'
      ? await api.restoreDatabase()
      : await api.rebuildDatabase();
  maintenanceMessage.value = result.message || 'Končano.';
  await loadMaintenance();
  if (action === 'restore' || action === 'rebuild') {
    await Promise.all([refreshSongs(), refreshAuthors(), refreshChoirs()]);
  }
}

async function downloadDatabase() {
  if (!requireEditor()) return;
  try {
    await api.downloadDatabase();
  } catch (error) {
    notifyError(error);
  }
}

async function saveAppClock() {
  if (!requireEditor()) return;
  const result = await api.setAppClock(appDate.value, appTime.value);
  maintenanceMessage.value = result.message || 'Datum/ura shranjena.';
  await loadMaintenance();
}

async function saveOperator() {
  if (!requireEditor()) return;
  const result = await api.setOperator(operatorName.value);
  operatorName.value = result.operator || operatorName.value || 'dusan';
  maintenanceMessage.value = result.message || 'Vnašalec shranjen.';
  await loadMaintenance();
}

function clearClassicViewData(view) {
  if (view === 'songs') {
    songs.value = [];
    selectedRows.value = [];
    clearSongContext();
    assign(songForm, emptySong());
  } else if (view === 'authors') {
    authors.value = [];
    selectedAuthorRows.value = [];
    clearAuthorContext();
    assign(authorForm, { id: null, name: '', type: 1 });
  } else if (view === 'choirs') {
    choirs.value = [];
    selectedChoirRows.value = [];
    clearChoirContext();
    assign(choirForm, { id: null, name: '', shortName: '' });
  } else if (view === 'reports') {
    reportText.value = '';
    reportRows.value = [];
  }
}

async function openView(view, { load = true } = {}) {
  await ensureBootstrap();
  cancelServicePassword();
  activeView.value = view;
  resetDosPosition();
  if (!load) {
    clearClassicViewData(view);
    return;
  }
  if (view === 'songs') await refreshSongs();
  if (view === 'authors') await refreshAuthors();
  if (view === 'choirs') await refreshChoirs();
  if (view === 'notes') await refreshNotes();
  if (view === 'reports') await generateReport();
  if (view === 'maintenance') await loadMaintenance();
  if (view === 'database') await refreshDatabase();
  if (theme.value === 'dos' && ['songs', 'authors', 'choirs'].includes(view)) {
    selectDosResult(0);
  }
}

function selectMain(index, activateExit = false) {
  if (introVisible.value) return;
  if (!isServiceMenu(index)) {
    cancelServicePassword();
  }
  if (theme.value === 'dos') {
    activeView.value = 'menu';
    closeLookup();
  }
  selectedMain.value = index;
  selectedChild.value = 0;
  menuLevel.value = 'main';
  if (!activateExit) return;
  if (menuItems[index]?.action === 'modern') {
    openModernUi();
    return;
  }
  if (menuItems[index]?.label === 'Konec') {
    logout();
    return;
  }
  if (menuItems[index]?.children?.length) {
    if (isServiceMenu(index)) {
      requestServicePassword();
      return;
    }
    menuLevel.value = 'child';
  }
}

function selectChild(index) {
  if (introVisible.value) return;
  selectedChild.value = index;
  menuLevel.value = 'child';
}

async function enterIntro() {
  loading.value = true;
  try {
    await ensureBootstrap();
    introVisible.value = false;
    activeView.value = theme.value === 'modern' ? 'songs' : 'menu';
    menuLevel.value = 'main';
    if (theme.value === 'modern') {
      await openView('songs');
    }
  } finally {
    loading.value = false;
  }
}

function returnToIntro() {
  introVisible.value = true;
  entryPasswordVisible.value = false;
  entryPassword.value = '';
  entryPasswordError.value = '';
  activeView.value = 'menu';
  selectedMain.value = 0;
  selectedChild.value = 0;
  menuLevel.value = 'main';
}

function isServiceMenu(index) {
  return menuItems[index]?.label === 'Servisni programi';
}

function requestServicePassword() {
  servicePassword.value = '';
  servicePasswordVisible.value = true;
  menuLevel.value = 'main';
  nextTick(() => servicePasswordInput.value?.focus());
}

function submitServicePassword() {
  if (servicePassword.value === 'cene' || servicePassword.value === 'CENE') {
    servicePasswordVisible.value = false;
    servicePassword.value = '';
    menuLevel.value = 'child';
    return;
  }
  cancelServicePassword();
}

function cancelServicePassword() {
  servicePasswordVisible.value = false;
  servicePassword.value = '';
}

function activateMain() {
  if (introVisible.value) {
    enterIntro();
    return;
  }
  if (menuItems[selectedMain.value].label === 'Konec') {
    logout();
    return;
  }
  if (menuItems[selectedMain.value].action === 'modern') {
    openModernUi();
    return;
  }
  if (isServiceMenu(selectedMain.value)) {
    requestServicePassword();
    return;
  }
  if (currentChildren.value.length) {
    menuLevel.value = 'child';
  }
}

async function activateChild() {
  if (introVisible.value) {
    enterIntro();
    return;
  }
  const child = currentChildren.value[selectedChild.value];
  if (!child) return;
  if (child.reportType) {
    reportType.value = child.reportType;
  }
  if (child.action === 'download-db') {
    await openView('maintenance');
    await downloadDatabase();
    return;
  }
  if (child.action) {
    await runMaintenanceAction(child.action);
    return;
  }
  await openView(child.view, { load: theme.value !== 'dos' });
}

function handleKeydown(event) {
  if (event.defaultPrevented) return;
  const tag = event.target?.tagName;
  const inField = ['INPUT', 'TEXTAREA', 'SELECT', 'BUTTON'].includes(tag);
  if (introVisible.value) {
    if (event.key === 'Escape' && entryPasswordVisible.value) {
      event.preventDefault();
      cancelEditorPassword();
    }
    if (event.key === ' ' && !entryPasswordVisible.value && !inField) {
      event.preventDefault();
      enterCatalogMode();
    }
    return;
  }
  if (theme.value === 'dos' && lookupVisible.value) {
    if (event.key === 'Escape' || event.key === 'F4') {
      event.preventDefault();
      closeLookup();
      return;
    }
    if (event.key === 'Enter' || event.key === 'F1') {
      event.preventDefault();
      applyLookupRow();
      return;
    }
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      selectLookupRow(lookupSelected.value + 1);
      return;
    }
    if (event.key === 'ArrowUp') {
      event.preventDefault();
      selectLookupRow(lookupSelected.value - 1);
      return;
    }
    if (event.key === 'PageDown') {
      event.preventDefault();
      selectLookupRow(lookupSelected.value + 12);
      return;
    }
    if (event.key === 'PageUp') {
      event.preventDefault();
      selectLookupRow(lookupSelected.value - 12);
      return;
    }
    if (event.key === 'Home') {
      event.preventDefault();
      selectLookupRow(0);
      return;
    }
    if (event.key === 'End') {
      event.preventDefault();
      selectLookupRow(lookupRows.value.length - 1);
      return;
    }
  }
  if (theme.value === 'dos') {
    if (event.key === 'F1') {
      event.preventDefault();
      confirmActiveDos();
      return;
    }
    if (event.key === 'F2' || event.key === 'F3') {
      event.preventDefault();
      $q.notify({ message: statusLine.value, timeout: 3000 });
      return;
    }
    if (event.key === 'F4') {
      event.preventDefault();
      if (activeView.value !== 'menu' && ['INPUT', 'TEXTAREA', 'SELECT'].includes(tag)) {
        moveDosField(-1);
      } else {
        goBackDos();
      }
      return;
    }
    if (event.key === 'F5') {
      event.preventDefault();
      listDosByCode();
      return;
    }
    if (event.key === 'F6') {
      event.preventDefault();
      listDosByAlpha();
      return;
    }
    if (event.key === 'F7') {
      event.preventDefault();
      contextualDosListOrReport('number');
      return;
    }
    if (event.key === 'F8') {
      event.preventDefault();
      contextualDosListOrReport('alpha');
      return;
    }
    if (event.key === 'F9') {
      event.preventDefault();
      $q.notify({ message: 'Prikaz okvirja osvežen.', timeout: 1500 });
      return;
    }
    if (event.key === 'F10') {
      event.preventDefault();
      deleteActiveDos();
      return;
    }
  }
  if (event.key === 'F2') {
    event.preventDefault();
    if (activeView.value === 'songs') saveSong();
    if (activeView.value === 'authors') saveAuthor();
    if (activeView.value === 'choirs') saveChoir();
    return;
  }
  if (event.key === 'F4') {
    event.preventDefault();
    (theme.value === 'dos' ? dosSearchInput.value : searchInput.value?.$el?.querySelector('input'))?.focus();
    return;
  }
  if (event.key === 'Escape') {
    if (theme.value === 'dos') {
      if (activeView.value !== 'menu' && inField) {
        resetDosFieldOrExit();
      } else {
        goBackDos();
      }
      event.preventDefault();
    }
    return;
  }
  if (theme.value === 'dos' && activeView.value !== 'menu' && inField) {
    if (event.key === 'Enter' || event.key === 'ArrowDown') {
      event.preventDefault();
      moveDosField(1);
      return;
    }
    if (event.key === 'ArrowUp') {
      event.preventDefault();
      moveDosField(-1);
      return;
    }
  }
  if (inField) return;
  if (theme.value === 'dos') {
    if (activeView.value === 'menu' && event.key === 'ArrowUp') {
      event.preventDefault();
      if (activeView.value === 'menu' && menuLevel.value === 'child' && currentChildren.value.length) {
        selectedChild.value = (selectedChild.value + currentChildren.value.length - 1) % currentChildren.value.length;
      } else {
        selectedMain.value = (selectedMain.value + menuItems.length - 1) % menuItems.length;
        selectedChild.value = 0;
        menuLevel.value = 'main';
      }
    }
    if (activeView.value === 'menu' && event.key === 'ArrowDown') {
      event.preventDefault();
      if (activeView.value === 'menu' && menuLevel.value === 'child' && currentChildren.value.length) {
        selectedChild.value = (selectedChild.value + 1) % currentChildren.value.length;
      } else {
        selectedMain.value = (selectedMain.value + 1) % menuItems.length;
        selectedChild.value = 0;
        menuLevel.value = 'main';
      }
    }
    if (activeView.value === 'menu' && event.key === 'ArrowRight') {
      event.preventDefault();
      activateMain();
    }
    if (event.key === 'ArrowLeft' && activeView.value === 'menu') {
      event.preventDefault();
      menuLevel.value = 'main';
    }
    if (event.key === 'Enter') {
      event.preventDefault();
      if (activeView.value === 'menu') {
        menuLevel.value === 'child' ? activateChild() : activateMain();
      } else {
        editActiveDosRow(activeDosRows()[selectedResult.value]);
      }
    }
    if (activeView.value !== 'menu' && activeDosRows().length) {
      if (event.key === 'PageDown') {
        event.preventDefault();
        selectDosResult(selectedResult.value + 10);
      }
      if (event.key === 'PageUp') {
        event.preventDefault();
        selectDosResult(selectedResult.value - 10);
      }
      if (event.key === 'Home') {
        event.preventDefault();
        selectDosResult(0);
      }
      if (event.key === 'End') {
        event.preventDefault();
        selectDosResult(activeDosRows().length - 1);
      }
      if (event.key === 'ArrowDown') {
        event.preventDefault();
        selectDosResult(selectedResult.value + 1);
      }
      if (event.key === 'ArrowUp') {
        event.preventDefault();
        selectDosResult(selectedResult.value - 1);
      }
    }
  } else if (['songs', 'authors', 'choirs'].includes(activeView.value)) {
    const rows = activeView.value === 'songs' ? songs.value : activeView.value === 'authors' ? authors.value : choirs.value;
    const selected = activeView.value === 'songs' ? selectedRows : activeView.value === 'authors' ? selectedAuthorRows : selectedChoirRows;
    const edit = activeView.value === 'songs' ? editSong : activeView.value === 'authors' ? editAuthor : editChoir;
    if (!rows.length) return;
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      navigateModernRows(rows, selected, edit, 1);
    }
    if (event.key === 'ArrowUp') {
      event.preventDefault();
      navigateModernRows(rows, selected, edit, -1);
    }
    if (event.key === 'Enter') {
      event.preventDefault();
      edit(selected.value[0] || rows[0]);
    }
  }
}

async function toggleTheme() {
  const nextTheme = theme.value === 'dos' ? 'modern' : 'dos';
  theme.value = nextTheme;
  if (nextTheme === 'modern') {
    if (activeView.value === 'menu') {
      await openView('songs');
    }
  } else if (activeView.value === 'database') {
    activeView.value = 'menu';
    menuLevel.value = 'main';
  }
  localStorage.setItem('melodija.theme', theme.value);
}

async function openModernUi() {
  if (theme.value !== 'modern') {
    await toggleTheme();
    return;
  }
  if (activeView.value === 'menu') {
    await openView('songs');
  }
}

watch(isReadOnly, async (readOnly) => {
  if (readOnly && ['notes', 'maintenance', 'database'].includes(activeView.value)) {
    await openView('songs');
  }
});

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
  initialize().catch((error) => {
    loading.value = false;
    $q.notify({ type: 'negative', message: error.message });
  });
});

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown);
});
</script>
