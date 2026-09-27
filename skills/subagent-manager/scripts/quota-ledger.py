"""Local snapshots only. Never contacts a provider or reads authentication."""
import argparse, contextlib, datetime as dt, json, math, os, pathlib, re, time, uuid
TZ=dt.timezone(dt.timedelta(hours=8))

def instant(value=None):
    stamp=dt.datetime.fromisoformat(value.replace('Z','+00:00')) if value else dt.datetime.now(dt.timezone.utc)
    if stamp.tzinfo is None: raise ValueError('Timestamp must include a UTC offset')
    return stamp.astimezone(TZ)

def report(state, now):
    if not state: return dict(status='unknown',tier='unknown',reason='no trustworthy snapshot')
    if state['day']!=now.date().isoformat():
        return dict(status='unknown',tier='unknown',reason='no snapshot for this local day',last_observed_at=state['last_at'])
    used=state['observed_daily_pp']
    tier='excess' if used>=200/7 else 'remind' if used>=150/7 else 'review' if used>=100/7 else 'normal'
    return dict(status='observed_lower_bound',tier=tier,observed_daily_pp=round(used,6),remaining_percent=state['remaining'],day=state['day'],last_observed_at=state['last_at'],coverage='partial; not an exact full-day total',gaps=state['gaps'])

def record(state, remaining, period, source, stamp):
    if not math.isfinite(remaining) or not 0<=remaining<=100:raise ValueError('remaining must be finite and between 0 and 100')
    if not period.strip() or len(period)>100:raise ValueError('A verified non-sensitive period ID is required')
    if not source.strip() or len(source)>64:raise ValueError('Use a short non-sensitive source label')
    day=stamp.date().isoformat()
    if state and stamp<=instant(state['last_at']):raise ValueError('Snapshot must be newer than the previous snapshot')
    if state and period==state['period'] and remaining>state['remaining']+1e-8:
        raise ValueError('Balance increased inside the same period; verify reset/correction before recording')
    if not state or state['day']!=day:
        new=dict(day=day,observed_daily_pp=0.0,gaps=['first snapshot is a lower-bound baseline; earlier daily usage is unknown'])
    else:
        new={**state,'gaps':list(state['gaps'])}
        if period==state['period']:
            new['observed_daily_pp']+=max(0,state['remaining']-remaining)
        else:
            new['gaps'].append('period changed; usage between the two snapshots is not attributable')
    new.update(remaining=remaining,period=period,source=source,last_at=stamp.isoformat())
    return new

@contextlib.contextmanager
def locked(folder):
    folder.mkdir(parents=True,exist_ok=True);lock=folder/'ledger.lock';fd=None;deadline=time.monotonic()+5
    while fd is None:
        try:fd=os.open(lock,os.O_CREAT|os.O_EXCL|os.O_WRONLY)
        except FileExistsError:
            if time.monotonic()>deadline:raise RuntimeError('Ledger busy or stale lock: verify no writer is running; do not silently remove the lock')
            time.sleep(.05)
    try:yield
    finally:os.close(fd);lock.unlink()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action',choices=['record','status'])
    parser.add_argument('--account',default='1');parser.add_argument('--remaining',type=float)
    parser.add_argument('--period');parser.add_argument('--source',default='manual-/usage')
    parser.add_argument('--at',help='Optional ISO timestamp with offset for imported snapshots/tests')
    default=pathlib.Path(os.environ.get('LOCALAPPDATA',str(pathlib.Path.home()/'.local/share')))/'subagent-manager/grok-quota'
    parser.add_argument('--state-dir',type=pathlib.Path,default=default)
    args=parser.parse_args()
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,32}',args.account):parser.error('Use a non-sensitive account label such as 1')
    try:
        stamp=instant(args.at)
        if args.action=='record' and (args.remaining is None or not args.period):raise ValueError('record requires --remaining and --period')
        path=args.state_dir/(args.account+'.json')
        if args.action=='status' and not args.state_dir.exists():print(json.dumps(report(None,stamp)));return
        with locked(args.state_dir):
            state=json.loads(path.read_text(encoding='utf-8')) if path.exists() else None
            if args.action=='record':
                state=record(state,args.remaining,args.period,args.source,stamp)
                temp=path.with_suffix('.'+uuid.uuid4().hex+'.tmp')
                temp.write_text(json.dumps(state,ensure_ascii=False,indent=2),encoding='utf-8');os.replace(temp,path)
            print(json.dumps(report(state,stamp),ensure_ascii=False,indent=2))
    except (ValueError,RuntimeError,OSError,json.JSONDecodeError) as exc:parser.exit(2,str(exc)+'\n')

if __name__=='__main__':main()
