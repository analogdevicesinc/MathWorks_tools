function SDUpdater(fhndl)

persistent app cleanup;

if ~isempty(cleanup)
    cleanup = [];
end

if ~ispc
    error('The SD Updater is only supported on Windows platforms');
end

app = feval(fhndl);
cleanup = onCleanup(@()delete(app));

