{{ define "bin" }}<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="Convenient file sharing. Think of it as Pastebin for files. Registration is not required. Large files are supported.">
        <meta name="author" content="Espen Braastad">
        <link rel="icon" href="/static/img/favicon.png">

        <link rel="preload" href="/static/webfonts/fa-regular-400.woff2" as="font">
        <link rel="preload" href="/static/webfonts/fa-solid-900.woff2" as="font">

        <link rel="stylesheet" href="/static/css/bootstrap.min.css"/>
        <link rel="stylesheet" href="/static/css/fontawesome.all.min.css"/>
        <link rel="stylesheet" href="/static/css/custom.css"/>

        <title>Filebin | {{ .Bin.Id }}</title>
        <script src="/static/js/upload.js"></script>
        {{ if eq .Bin.Readonly false }}
        <script>
            window.onload = function () {
                if (typeof FileReader == "undefined") alert ("Your browser \
                    is not supported. You will need to use a \
                    browser with File API support to upload files.");
                var fileCount = document.getElementById("fileCount");
                var fileList = document.getElementById("fileList");
                var fileDrop = document.getElementById("fileDrop");
                var fileField = document.getElementById("fileField");
                var bin = "{{ .Bin.Id }}";
                var binURL = "/{{ .Bin.Id }}";
                var client = new ClientJS();
                FileAPI = new FileAPI(
                    fileCount,
                    fileList,
                    fileDrop,
                    fileField,
                    bin,
                    binURL,
                    client.getFingerprint()
                );
                FileAPI.init();
                // Automatically start upload when using the drop zone
                fileDrop.ondrop = FileAPI.uploadQueue;
                // Automatically start upload when selecting files
                if (fileField) {
                    fileField.addEventListener("change", FileAPI.uploadQueue)
                }
            }
        </script>
        {{ end }}
    </head>
    <body class="container-xl">

        {{ template "topbar" . }}

        <h1>Filebin</h1>

        {{ if eq .Bin.Readonly false }}
            <!-- Upload status -->
            <span id="fileCount"></span>

            <!-- Drop zone -->
            <span id="fileDrop"></span>

            <!-- Upload queue -->
            <span id="fileList"></span>
        {{ end }}

        {{ $numfiles := .Files | len }}
        
        <p class="lead">
        {{ if isAvailable .Bin }}
            {{ if eq $numfiles 0 }}
                {{ if eq .Bin.Readonly false }}
                    <div>This bin is empty. To upload files, click <em>Upload files</em> below or drag-and-drop the files into this browser window.</div>

                    <div class="mt-3 fileUpload btn btn-primary">
                        <span><i class="fa fa-cloud-upload"></i> Upload files</span>
                        <input type="file" class="upload" id="fileField" multiple/>
                    </div>
                {{ else }}
                    <div>This bin is empty. Files can not be uploaded to it since it is locked.</div>
                {{ end }}
            {{ else }}
                The bin <a class="link-primary link-custom" href="/{{ .Bin.Id }}">{{ .Bin.Id }}</a> was created {{ .Bin.CreatedAtRelative }}

                {{- if ne .Bin.CreatedAtRelative .Bin.UpdatedAtRelative -}}
                    , updated {{ .Bin.UpdatedAtRelative }}
                {{ end }}

                and it expires {{ .Bin.ExpiredAtRelative }}.
                It contains {{ .Files | len }}

                {{ if eq $numfiles 1 }}file at {{ .Bin.BytesReadable }}.{{ end }}
                    {{ if gt $numfiles 1 }}files at {{ .Bin.BytesReadable }} in total.{{ end }}
                {{ end }}

                {{ if isApproved $.Bin }}
                {{ else }}
                    {{ if gt $numfiles 0 }}
                        It is pending approval <a href="#" data-bs-toggle="modal" data-bs-target="#modalApprovalInfo"><i class="far fa-question-circle"></i></a>.
                    {{ end }}
                {{ end }}
            {{ else }}
                <div>This bin is no longer available.</div>
            {{ end }}
        </p>

        {{ if gt $numfiles 0 }}
            <p>
                <ul class="nav nav-pills">
                    <li class="nav-item me-3">
                        <a class="btn btn-primary" href="#" data-bs-toggle="modal" data-bs-target="#modalArchive">
                            <i class="fas fa-fw fa-cloud-download-alt"></i> Download files
                        </a>
                    </li>

                    <li class="nav-item">
                        <div class="dropdown">
                                <a class="btn btn-primary dropdown-toggle text-white" href="#" id="dropdownBinMenuButton" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    More
                                </a>
                                <ul class="dropdown-menu dropdown-menu-right" aria-labelledby="dropdownBinMenuButton">
                                    {{ if eq .Bin.Readonly false }}
                                        <li>
                                            <span class="dropdown-item fileUpload">
                                                <span>
                                                    <i class="fas fa-fw fa-cloud-upload-alt text-primary"></i> Upload more files
                                                </span>
                                                <input type="file" class="upload" id="fileField" multiple/>
                                            </span>
                                        </li>
                                    {{ end }}
                                    <li>
                                        <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalBinProperties" aria-haspopup="true" aria-expanded="false">
                                            <i class="fas fa-fw fa-info-circle text-primary"></i> Bin properties
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalBinQR" aria-haspopup="true" aria-expanded="false">
                                            <i class="fas fa-fw fa-qrcode text-primary"></i> QR code
                                        </a>
                                    </li>
                                    <li>
                                    <div class="dropdown-divider"></div>
                                    </li>
                                    {{ if eq .Bin.Readonly false }}
                                    <li>
                                        <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalLockBin" aria-haspopup="true" aria-expanded="false">
                                            <i class="fas fa-fw fa-lock text-warning"></i> Lock bin
                                        </a>
                                    </li>
                                    {{ end }}
                                    <li>
                                    <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalDeleteBin">
                                        <i class="far fa-fw fa-trash-alt text-danger"></i> Delete bin
                                    </a>
                                    </li>
                                </ul>
                        </div>
                    </li>
                </ul>
            </p>
        {{ end }}

        {{ if .Files }}
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th scope="col">Filename</th>
                        <th scope="col">Content type</th>
                        <th scope="col">Size</th>
                        <th scope="col">Uploaded</th>
                        <th scope="col"></th>
                    </tr>
                </thead>
                <tbody>
                    {{ range $index, $value := .Files }}
                        <tr>
                            <td>
                                {{ if eq .Category "image" }}
                                    <i class="far fa-fw fa-file-image"></i>
                                {{ else }}
                                    {{ if eq .Category "video" }}
                                        <i class="far fa-fw fa-file-video"></i>
                                    {{ else }}
                                        <i class="far fa-fw fa-file"></i>
                                    {{ end }}
                                {{ end }}
                                {{ if isApproved $.Bin }}
                                    <a class="link-primary link-custom" href="{{ .URL }}">{{ .Filename }}</a>
                                {{ else }}
                                    {{ .Filename }}
                                {{ end }}
                            </td>
                            <td>
                                {{ .Mime }}
                            </td>
                            <td>
                                {{ .BytesReadable }}
                            </td>
                            <td>
                                {{ .UpdatedAtRelative }}
                            </td>
                            <td>
                                <div class="dropdown">
                                    <a class="dropdown-toggle small link-custom" href="#" id="dropdownFileMenuButton" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        More
                                    </a>
                                    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="dropdownFileMenuButton">
                                        {{ if isApproved $.Bin }}
                                            <a class="dropdown-item" href="{{ .URL }}">
                                                <i class="fas fa-fw fa-cloud-download-alt text-primary"></i> Download file
                                            </a>
                                        {{ end }}
                                        <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalFileProperties-{{ $index }}">
                                            <i class="fas fa-fw fa-info-circle text-primary"></i> File properties
                                        </a>
                                        <div class="dropdown-divider"></div>
                                        <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalDeleteFile-{{ $index }}">
                                            <i class="far fa-fw fa-trash-alt text-danger"></i> Delete file
                                        </a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    {{ end }}
                </tbody>
            </table>
        {{ end }}

        <!-- Download archive modal start -->
        <div class="modal fade" id="modalArchive" tabindex="-1" role="dialog" aria-labelledby="modalArchiveTitle" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="modalArchiveTitle">Download files</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>
                            The files in this bin can be downloaded as a single file archive. The default filename of the archive is <code>{{ .Bin.Id }}</code> and the size is {{ .Bin.BytesReadable }} uncompressed.
                        </p>

                        {{ if isApproved $.Bin }}
                            <p class="lead">Select archive format to download:</p>

                            <ul class="nav nav-pills">
                                <li class="nav-item me-3">
                                    <a class="btn btn-primary" href="/archive/{{ $.Bin.Id }}/tar"><i class="fas fa-fw fa-file-archive"></i> Tar</a>
                                </li>
                                <li class="nav-item">
                                    <a class="btn btn-primary" href="/archive/{{ $.Bin.Id }}/zip"><i class="fas fa-fw fa-file-archive"></i> Zip</a>
                                </li>
                            </ul>
                        {{ else }}
                            <p>Downloads are not allowed as the bin is pending approval.</p>
                        {{ end }}
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Download archive modal end -->

        <!-- Delete bin modal start -->
        <div class="modal fade" id="modalDeleteBin" tabindex="-1" role="dialog" aria-labelledby="modalDeleteBinTitle" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header alert-secondary">
                        <h5 class="modal-title" id="modalDeleteBinTitle">Delete bin</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>You are free to delete this bin. However you are encouraged to delete your own bins only, or bins that are being used to share obvious illegal, copyrighted or malicious content. Bins that are deleted can not be reused.</p>

                        <p>This action is not reversible.</p>

                        <p class="lead">Delete the bin <a class="link-primary" href="/{{ $.Bin.Id }}">{{ $.Bin.Id }}</a> and all of its files?</p>

                        <div id="deleteStatus"></div>
                    </div>
                    <div class="modal-footer">
                        <div class="pull-left">
                        <button type="button" class="btn btn-danger" id="deleteButton" onclick="deleteURL('/{{ $.Bin.Id }}','deleteStatus')"><i class="fas fa-fw fa-trash-alt"></i> Confirm</button>
                        </div>
                        <a href="/{{ $.Bin.Id }}" class="btn btn-secondary"><i class="fa fa-close"></i> Close</a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Delete bin modal end -->

        <!-- Bin properties modal start -->
        <div class="modal fade" id="modalBinProperties" tabindex="-1" role="dialog" aria-labelledby="modalBinPropertiesTitle" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header alert-secondary">
                        <h5 class="modal-title" id="modalBinPropertiesTitle">Bin properties</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <dl class="row">
                            <dt class="col-sm-3">Bin</dt>
                            <dd class="col-sm-9">
                                <a class="link-primary link-custom" href="/{{ $.Bin.Id }}">
                                    {{ $.Bin.Id }}
                                </a>
                            </dd>

                            <dt class="col-sm-3">Number of files</dt>
                            <dd class="col-sm-9">
                                {{ $.Files | len }}
                            </dd>

                            <dt class="col-sm-3">Total size</dt>
                            <dd class="col-sm-9">
                                {{ $.Bin.BytesReadable }} ({{ $.Bin.Bytes }} bytes)
                            </dd>

                            <dt class="col-sm-3">Status</dt>
                            <dd class="col-sm-9">
                                {{ if $.Bin.Readonly }}
                                    Locked, which means that new files can not be uploaded and existing files can not be updated.
                                {{ else }}
                                    Unlocked, which means that files can be uploaded and updated.
                                {{ end }}
                            </dd>

                            <dt class="col-sm-3">Created</dt>
                            <dd class="col-sm-9">
                                {{ $.Bin.CreatedAtRelative }}
                                ({{ $.Bin.CreatedAt.Format "2006-01-02 15:04:05 UTC" }})
                            </dd>

                            <dt class="col-sm-3">Approved</dt>
                            <dd class="col-sm-9">
                                {{ if isApproved $.Bin }}
                                    {{ $.Bin.ApprovedAtRelative }}
                                    ({{ $.Bin.ApprovedAt.Time.Format "2006-01-02 15:04:05 UTC" }})
                                {{ else }}
                                    Pending approval, which means that file downloads are not yet allowed.
                                {{ end }}
                            </dd>

                            <dt class="col-sm-3">Last updated</dt>
                            <dd class="col-sm-9">
                                {{ $.Bin.UpdatedAtRelative }}
                                ({{ $.Bin.UpdatedAt.Format "2006-01-02 15:04:05 UTC" }})
                            </dd>

                            <dt class="col-sm-3">Expires</dt>
                            <dd class="col-sm-9">
                                {{ if $.Bin.ExpiredAtRelative }}
                                    {{ $.Bin.ExpiredAtRelative }}
                                {{ end }}
                                ({{ $.Bin.ExpiredAt.Format "2006-01-02 15:04:05 UTC" }})
                            </dd>
                        </dl>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Bin properties modal end -->

        <!-- Bin QR code modal start -->
        <div class="modal fade" id="modalBinQR" tabindex="-1" role="dialog" aria-labelledby="modalBinQRTitle" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header alert-secondary">
                        <h5 class="modal-title" id="modalBinQRTitle">QR code</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>The URL to this bin is <a href="{{ .BinUrl }}">{{ .BinUrl }}</a>, which is embedded in the QR code below. This can be used to conveniently share the URL across mobile devices without having to type out the URL.</p>

                        <div class="text-center">
                            <img src="/qr/{{ $.Bin.Id }}" alt="QR code for {{ .BinUrl }}"/>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Bin QR code modal end -->

        <!-- Lock bin modal start -->
        <div class="modal fade" id="modalLockBin" tabindex="-1" role="dialog" aria-labelledby="modalLockBinTitle" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header alert-secondary">
                        <h5 class="modal-title" id="modalLockBinTitle">Lock bin</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>The bin is currently unlocked, which means that new files can be added to it and existing files can be updated. If the bin is locked, the bin will become read only and no more file uploads will be allowed. Note that a locked bin can still be deleted.</p>
                <p>This action is not reversible.</p>

                        <p class="lead">Do you want to lock bin <a class="link-primary" href="/{{ $.Bin.Id }}">{{ $.Bin.Id }}</a>?</p>

                        <div id="lockStatus"></div>
                    </div>
                    <div class="modal-footer">
                        <div class="pull-left">
                        <button type="button" class="btn btn-warning" id="lockButton" onclick="lockBin('{{ $.Bin.Id }}','lockStatus')"><i class="fas fa-fw fa-lock"></i> Confirm</button>
                        </div>
                        <a href="/{{ $.Bin.Id }}" class="btn btn-secondary"><i class="fa fa-close"></i> Close</a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Lock bin modal end -->

        <!-- Delete file modal start -->
        {{ range $index, $value := .Files }}
            <div class="modal fade" id="modalDeleteFile-{{ $index }}" tabindex="-1" role="dialog" aria-labelledby="modalDeleteFileTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header alert-secondary">
                            <h5 class="modal-title" id="modalDeleteFileTitle">Delete file</h5>
                            <!--<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>-->
                            <a class="btn-close" href="/{{ $.Bin.Id }}"></a>
                        </div>
                        <div class="modal-body">
                            <p>You are free to delete any file in this bin. However you are encouraged to delete the files that you have uploaded only, or files with obvious malicious or illegal content.</p>
                            <p>This action is not reversible.</p>

                            <p class="lead">Delete the file
                                {{ if isApproved $.Bin }}
                                    <a class="link-primary" href="/{{ $.Bin.Id }}/{{ .Filename }}">{{ .Filename }}</a>
                                {{ else }}
                                    {{ .Filename }}
                                {{ end }}
                                ?
                            </p>

                            <div id="deleteStatus-{{ $index }}"></div>
                        </div>
                        <div class="modal-footer">
                            <div class="pull-left">
                            <button type="button" class="btn btn-danger" id="deleteButton" onclick="deleteURL('/{{ $.Bin.Id }}/{{ .Filename }}','deleteStatus-{{ $index }}')"><i class="fas fa-fw fa-trash-alt"></i> Confirm</button>
                            </div>
                            <a href="/{{ $.Bin.Id }}" class="btn btn-secondary"><i class="fa fa-close"></i> Close</a>
                        </div>
                    </div>
                </div>
            </div>
        {{ end }}
        <!-- Delete file modal end -->

        <!-- File properties modal start -->
        {{ range $index, $value := .Files }}
            <div class="modal fade" id="modalFileProperties-{{ $index }}" tabindex="-1" role="dialog" aria-labelledby="modalFilePropertiesTitle" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header alert-secondary">
                            <h5 class="modal-title" id="modalFilePropertiesTitle">File properties</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <dl class="row">
                                <dt class="col-sm-3">Filename</dt>
                                <dd class="col-sm-9">
                                    {{ if isApproved $.Bin }}
                                        <a class="link-primary link-custom" href="{{ .URL }}">{{ .Filename }}</a>
                                    {{ else }}
                                        {{ .Filename }}
                                    {{ end }}
                                </dd>

                                <dt class="col-sm-3">Bin</dt>
                                <dd class="col-sm-9">
                                    <a class="link-primary link-custom" href="/{{ $.Bin.Id }}">
                                        {{ $.Bin.Id }}
                                    </a>
                                </dd>

                                <dt class="col-sm-3">File size</dt>
                                <dd class="col-sm-9">
                                    {{ .BytesReadable }} ({{ .Bytes }} bytes)
                                </dd>

                                {{ if ne .CreatedAt .UpdatedAt }}
                                    <dt class="col-sm-3">Update count</dt>
                                    <dd class="col-sm-9">
                                        {{ .Updates }}
                                    </dd>

                                    <dt class="col-sm-3">Last updated</dt>
                                    <dd class="col-sm-9">
                                        {{ .UpdatedAtRelative }}
                                        ({{ .UpdatedAt.Format "2006-01-02 15:04:05 UTC" }})
                                    </dd>
                                {{ end }}

                                <dt class="col-sm-3">Created</dt>
                                <dd class="col-sm-9">
                                    {{ .CreatedAtRelative }}
                                    ({{ .CreatedAt.Format "2006-01-02 15:04:05 UTC" }})
                                </dd>

                                <dt class="col-sm-3">Expires</dt>
                                <dd class="col-sm-9">
                                    {{ if $.Bin.ExpiredAtRelative }}
                                        {{ $.Bin.ExpiredAtRelative }}
                                    {{ end }}
                                    ({{ $.Bin.ExpiredAt.Format "2006-01-02 15:04:05 UTC" }})
                                </dd>
                            </dl>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        {{ end }}
        <!-- File properties modal end -->

        <!-- Approval Info Modal start -->
        <div class="modal fade" id="modalApprovalInfo" tabindex="-1" role="dialog" aria-labelledby="modalApprovalInfoTitle" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header alert-secondary">
                        <h5 class="modal-title" id="modalApprovalInfoTitle">Pending approval</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>This bin is pending administrator approval.</p>
                        <p>While the bin is pending approval, files can be added, updated and deleted as normal and the bin can also be locked. File downloads and archive downloads, however, will be rejected until the bin is approved.</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Approval Info Modal stop -->

        {{ template "footer" . }}
        <script src="/static/js/popper.min.js"></script>
        <script src="/static/js/bootstrap.min.js"></script>
        <script src="/static/js/client.min.js"></script>
    </body>
</html>
{{ end }}
